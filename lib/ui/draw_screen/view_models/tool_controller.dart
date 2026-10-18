import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/property_data/property_data.dart';
import 'package:drawing_app/domain/models/property_data/property_type.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/circle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/line_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/override_drawn.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/path_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/rectangle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/select_tool.dart';
import 'package:drawing_app/ui/core/tool_input_handler/mouse_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/touch_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/trackpad_input_handler.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:drawing_app/ui/core/draw_tools/history_consumer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:material_symbols_icons/symbols.dart';

class ToolController extends ChangeNotifier {
  // final DrawScreenViewModel 

  final VoidCallback onForceCanvasRefresh;
  
  final Function(CanvasCommand canvasCommand) onExecuteCommand;
  final List<DrawData> Function() getGlobalHistory;
  final Size Function() getCanvasDimensions;
  final String Function() getActiveLayerId;
  final Offset Function(Offset screenPoint) getSnappedWorldPoint;
  final VoidCallback onClearSnapping;

  final ToolMatrixPayload camera;

  // DEBUG
  ScaleStartDetails? startDetails;
  ScaleUpdateDetails? updateDetails;

  final Set<int> _activePointerIds = {};
  Set<int> get activePointerIds => _activePointerIds;

  late final Map<PointerDeviceKind, ToolInputHandler> _inputHandlers;
  Map<PointerDeviceKind, ToolInputHandler> get inputHandlers => _inputHandlers;

  late PanTool _panTool;

  /// 🟢 CONFORMS TO MVVM: Normalizes what needs to be painted on the
  /// real-time preview overlay track layer, freeing the view from collection filtering math.
  List<DrawData> get overlayHistory {
    // 1. If a standard tool (like Freehand/Rectangle) has an active preview, paint it
    if (activePreview.isNotEmpty) {
      return activePreview;
    }

    // 2. If the eraser is sweeping across the canvas, grab ONLY the targets
    if (_currentTool is EraseTool && activeDeletionTargets.isNotEmpty) {
      return getGlobalHistory()
          .where((shape) => activeDeletionTargets.contains(shape.id))
          .toList();
    }

    // 3. Otherwise, paint an empty list
    return const [];
  }

  Set<String> get activeDeletionTargets {
    if (_currentTool is EraseTool) {
      return (_currentTool as EraseTool).targetedForDeletion;
    }
    return const {};
  }

  Set<String> get hiddenData{
    if(_currentTool is OverrideDrawn){
      return(_currentTool as OverrideDrawn).hiddenDrawDataIds;
    } else{
      return const {};
    }
  }

  late final Map<Type, CanvasTool> tools;
  late CanvasTool _currentTool;

  final Logger _logger;

  List<DrawData> get activePreview => _currentTool is DrawTool
      ? (_currentTool as DrawTool).activePreview
      : const [];

  ToolController({required Logger logger, required this.onForceCanvasRefresh, required this.onExecuteCommand, required this.getGlobalHistory, required this.getCanvasDimensions, required this.getActiveLayerId, required this.getSnappedWorldPoint, required this.onClearSnapping, required this.camera})
    : _logger = logger{
    initializeTools();

    _inputHandlers = {
      PointerDeviceKind.mouse: MouseInputHandler(
        onToolPress: (p0) => handleToolPressed(p0),
        onToolUpdate: (p0) => handleToolUpdate(p0),
        onToolRelease: (toolInput) => handleToolReleased(toolInput),
        onPanStart: (toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        snappedScreenPointConverter: (screenPoint) =>
            getSnappedWorldPoint(screenPoint),
        unsnappedScreenPointConverter: (screenPoint) => screenPoint.screenToWorld(camera.transform),
      ),
      PointerDeviceKind.touch: TouchInputHandler(
        onToolPress: (p0) => handleToolPressed(p0),
        onToolUpdate: (p0) => handleToolUpdate(p0),
        onToolRelease: (toolInput) => handleToolReleased(toolInput),
        onPanStart: (toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        snappedScreenPointConverter: (screenPoint) =>
            getSnappedWorldPoint(screenPoint),
        unsnappedScreenPointConverter: (screenPoint) => screenPoint.screenToWorld(camera.transform),
      ),
      PointerDeviceKind.trackpad: TrackpadInputHandler(
        onToolPress: (_) {},
        onToolUpdate: (_) {},
        onToolRelease: (_) {},
        onPanStart: (toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        snappedScreenPointConverter: (screenPoint) =>
            getSnappedWorldPoint(screenPoint),
        unsnappedScreenPointConverter: (screenPoint) => screenPoint.screenToWorld(camera.transform),
      ),
    };
  }

  PointerDeviceKind get lastDeviceKind => _lastDeviceKind;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;
  bool drawEnabled = true;

  CanvasTool get currentTool => _currentTool;

  final Map<PropertyId, ValueNotifier<dynamic>> _propertyNotifierCache = {};

  List<PropertyData> get loadedProperties => _currentTool.toolProperties;

  ValueNotifier<T>? getNotifierForProperty<T>(PropertyId id) {
  if (_propertyNotifierCache.containsKey(id)) {
    return _propertyNotifierCache[id] as ValueNotifier<T>?;
  }

  final properties = loadedProperties;
  PropertyData? match;
  
  for (final p in properties) {
    if (p.id == id) {
      match = p;
      break;
    }
  }

  if (match == null) return null;

  final notifier = ValueNotifier<T>(match.value as T);
  _propertyNotifierCache[id] = notifier;
  
  return notifier;
}


  void updateToolProperty(PropertyId id, dynamic newValue){
    if(_propertyNotifierCache.containsKey(id)){
      _propertyNotifierCache[id]!.value = newValue;
    }

    _currentTool.updatePropertyStateValue(id, newValue);
  }


  void handleEvent<T>(T event, PointerDeviceKind device) {
    if (inputHandlers[device] == null) return; //For unsupported devices
    if (_lastDeviceKind != PointerDeviceKind.unknown &&
        _lastDeviceKind != device) {
      inputHandlers[_lastDeviceKind]!.disableInput();
    }
    inputHandlers[device]!.handleEvent(event, camera.transform);
    _lastDeviceKind = device;
  }

  void handleToolPressed(ToolStartInput input) {
    if (!drawEnabled || _panTool.isActive) return;

    if (_currentTool is PanTool) {
      handlePanStart(input);
      return;
    } else if (input.snappedWorldPoint.dx < 0 ||
        input.snappedWorldPoint.dx > getCanvasDimensions().width ||
        input.snappedWorldPoint.dy < 0 ||
        input.snappedWorldPoint.dy > getCanvasDimensions().height) {
      onClearSnapping();
      return;
    } else if (!_currentTool.isActive) {
      onClearSnapping();
    }

    if (_currentTool is HistoryConsumer) {
      (_currentTool as HistoryConsumer).setHistorySnapshot(
        getGlobalHistory(),
      );
    }

    _lastDeviceKind = input.kind;
    _currentTool.onToolStart(
      input,
      getActiveLayerId(),
      getGlobalHistory().length,
    );

    notifyListeners();
  }

  void handleToolUpdate(ToolUpdateInput input) {
    if (!drawEnabled) return;

    if (_currentTool is PanTool) {
      handlePanUpdate(input);
      return;
    } else if (!_currentTool.isActive) {
      return;
    }

    _lastDeviceKind = input.kind;
    _currentTool.onToolUpdate(input, getActiveLayerId());

    notifyListeners();
  }

  void handleToolReleased(ToolReleasedInput input) {
    if (!drawEnabled || !_currentTool.isActive) return;
    onClearSnapping();
    _endActiveTool();
  }

  void handlePanStart(ToolStartInput input) {
    if (_currentTool is DrawTool) {
      // _endActiveTool();
      CanvasCommand? command = (_currentTool as DrawTool).onPanOverrideStart();

      if(command != null){
        onExecuteCommand(command);
        notifyListeners();
      }
    }


    camera.focalPointAtStart = input.snappedScreenPoint;
    camera.scaleStart = camera.currentScale;
    camera.previousGestureScale = 1.0;
    camera.worldPivotAtStart = input.snappedWorldPoint;

    _lastDeviceKind = input.kind;
    _panTool.onToolStart(
      input,
      getActiveLayerId(),
      getGlobalHistory().length,
    );
    notifyListeners();
  }

  void handlePanUpdate(ToolUpdateInput input) {
    if (!_panTool.isActive) return;

    _lastDeviceKind = input.kind;
    _panTool.onToolUpdate(input, getActiveLayerId());
    onForceCanvasRefresh();
    notifyListeners();
  }

  void handlePanEnd(ToolReleasedInput input) {
  if (!_panTool.isActive) return;
  _lastDeviceKind = input.lastUsedDevice;
  _panTool.onToolEnd();


  // FIX: Force the snapping tracking variables to wipe clean!
  // This resets '_lastSnappedWorldPoint = null' in your View Model,
  // so the very next mouse movement initializes an accurate base anchor.
  onClearSnapping(); 
  
  if(_currentTool is DrawTool){
   (_currentTool as DrawTool).onPanOverrideEnd();
  }

  notifyListeners();
}

  void initializeTools({Type? initialTool}) {
    tools = {
      FreehandTool: FreehandTool(
        toolName: 'Freehand Tool',
        toolIcon: Icon(Icons.draw),
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser),
      ),
      CircleTool: CircleTool(
        toolIcon: Icon(Icons.circle),
        toolName: 'Circle Tool',
      ),
      RectangleTool: RectangleTool(
        toolName: 'Rectangle Tool',
        toolIcon: Icon(Icons.square),
      ),
      LineTool: LineTool(
        toolIcon: Icon(Icons.horizontal_rule),
        toolName: 'Line Tool',
      ),
      PathTool: PathTool(
        toolIcon: Icon(Icons.polyline),
        toolName: 'Path Tool',
      ),
      SelectTool  :SelectTool(toolName: 'Select Tool', toolIcon: Icon(Icons.near_me))
    };
    if (initialTool != null) {
      _currentTool = tools.containsKey(initialTool)
          ? tools[initialTool]!
          : tools.values.first;
    } else {
      _currentTool = tools[PanTool]!;
    }

    _panTool = tools[PanTool]! as PanTool;
  }

  void selectTool<T extends CanvasTool>() {
    
    final targetTool = tools[T];
    if (targetTool == null || targetTool == _currentTool) return;

    // clear its caches, and emit any final transformation commands before swapping
    if (_currentTool.isActive) {
      final finalCommand = _currentTool.onToolEnd();
      if (finalCommand != null) {
        onExecuteCommand(finalCommand);
      }

      //To kill any tools that won't necessarily stop drawing when calling onToolEnd
      _currentTool.cancel();
    }

    _propertyNotifierCache.clear();
    _currentTool = targetTool;
    notifyListeners();
  }

  void _endActiveTool() {
    if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) {
        onExecuteCommand(command);
      }
      notifyListeners();
    }
  }

  void disableDrawing() {
    // If a simple gesture tool is actively drawing, commit its current stroke safely
    inputHandlers[lastDeviceKind]?.disableInput();
    if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) onExecuteCommand(command);
    }

    // Hard-cancel the active drawing tool context
    // This explicitly flushes multi-stroke coordinate arrays (like PathTool)
    // to prevent ghost paths when drawing is later re-enabled
    _currentTool.cancel();

    // Cleanly tear down any active temporal viewport pan matrix loops
    if (_panTool.isActive) {
      _panTool.onToolEnd();
    }

    // Force reset all environmental gesture variables
    drawEnabled = false;

    // Clear out stored gesture history objects to prevent stale tracking updates
    updateDetails = null;
    startDetails = null;

    notifyListeners();
  }

  void enableDrawing(PointerEnterEvent event) {
    // Clear input gesture details cache completely
    startDetails = null;
    updateDetails = null;

    // Open the drawing state gates safely
    drawEnabled = true;

    notifyListeners();
  }
}
