import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/domain/models/tool_input_data/tool_input_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/circle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/line_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/path_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/rectangle_tool.dart';
import 'package:drawing_app/ui/core/tool_input_handler/mouse_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/tool_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/touch_input_handler.dart';
import 'package:drawing_app/ui/core/tool_input_handler/trackpad_input_handler.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ToolController extends ChangeNotifier {
  final DrawScreenViewModel _viewModel;

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
    if (activePreview != null) {
      return [activePreview!];
    }

    // 2. If the eraser is sweeping across the canvas, grab ONLY the targets
    if (_currentTool is EraseTool && activeDeletionTargets.isNotEmpty) {
      return _viewModel.drawHistory
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



  late final Map<Type, CanvasTool> tools;
  late CanvasTool _currentTool;

  DrawData? get activePreview => _currentTool is DrawTool ? (_currentTool as DrawTool).activePreview : null;

  ToolController({required DrawScreenViewModel viewModel})
    : _viewModel = viewModel {
    initializeTools();

    _inputHandlers = {
      PointerDeviceKind.mouse : MouseInputHandler(
        onToolPress: (p0) => handleToolPressed(p0), 
        onToolUpdate: (p0) => handleToolUpdate(p0), 
        onToolRelease: (toolInput) => handleToolReleased(toolInput), 
        onPanStart: (toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        screenPointConverter: (screenPoint) => _viewModel.getSnappedWorldPoint(screenPoint),
      ),
      PointerDeviceKind.touch : TouchInputHandler(
        onToolPress: (p0) => handleToolPressed(p0), 
        onToolUpdate: (p0) => handleToolUpdate(p0), 
        onToolRelease: (toolInput) => handleToolReleased(toolInput), 
        onPanStart: (toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        screenPointConverter: (screenPoint) => _viewModel.getSnappedWorldPoint(screenPoint),
      ),
      PointerDeviceKind.trackpad: TrackpadInputHandler(
        onToolPress: (_){},
        onToolUpdate: (_){},
        onToolRelease: (_){},
        onPanStart:(toolInput) => handlePanStart(toolInput),
        onPanUpdate: (toolInput) => handlePanUpdate(toolInput),
        onPanEnd: (toolInput) => handlePanEnd(toolInput),
        screenPointConverter: (screenPoint) => _viewModel.getSnappedWorldPoint(screenPoint),
      ),
    };
  }

  PointerDeviceKind get lastDeviceKind => _lastDeviceKind;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;
  bool drawEnabled = true;

  CanvasTool get currentTool => _currentTool;

  void handleEvent<T>(T event, PointerDeviceKind device){
    if(inputHandlers[device] == null) return; //For unsupported devices
    if(_lastDeviceKind != PointerDeviceKind.unknown && _lastDeviceKind != device){
      inputHandlers[_lastDeviceKind]!.disableInput();
    }
    inputHandlers[device]!.handleEvent(event, _viewModel.camera.transform);
    _lastDeviceKind = device;
    
  }

  void handleToolPressed(ToolStartInput input){
    if(!drawEnabled || _panTool.isActive) return;  

    if(_currentTool is PanTool){
      handlePanStart(input);
      return;
    } else if(input.worldPoint.dx < 0 || input.worldPoint.dx > _viewModel.currentCanvas.currentWidth || input.worldPoint.dy < 0 || input.worldPoint.dy > _viewModel.currentCanvas.currentHeight){
      _viewModel.clearSnappingSession();
      return;
    } else if(!_currentTool.isActive){
          _viewModel.clearSnappingSession();
    }

    

    if(_currentTool is HistoryConsumer){
      (_currentTool as HistoryConsumer).setHistorySnapshot(_viewModel.drawHistory);
    }

    _lastDeviceKind = input.kind;
    _currentTool.onToolStart(input, _viewModel.activeLayerId, _viewModel.drawHistory.length);

    
    notifyListeners();


  }

  void handleToolUpdate(ToolUpdateInput input){
    
    if(!drawEnabled) return;

    if(_currentTool is PanTool){
      handlePanUpdate(input);
      return;
    } else if(!_currentTool.isActive){
      return;
    }

    _lastDeviceKind = input.kind;
    _currentTool.onToolUpdate(input, _viewModel.activeLayerId);

    notifyListeners();
    }

  

  void handleToolReleased(ToolReleasedInput input){
    if(!drawEnabled || !_currentTool.isActive) return;
    _viewModel.clearSnappingSession();
    _endActiveTool();
    
  }

  void _endActiveTool(){
        if(_currentTool.isActive){
      final command = _currentTool.onToolEnd();
      if(command != null){
        _viewModel.executeCommand(command);
      }
        notifyListeners();
      }
  }

  void handlePanStart(ToolStartInput input){

    // if(_panTool.isActive) return;

      // If we are about to override the currently selected tool end it
    if(_currentTool is !PanTool){_endActiveTool();}



      _viewModel.camera.focalPointAtStart = input.screenPoint;
  _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
  _viewModel.camera.previousGestureScale = 1.0;
  _viewModel.camera.worldPivotAtStart = input.worldPoint;
  

    _lastDeviceKind = input.kind;
    _panTool.onToolStart(input, _viewModel.activeLayerId, _viewModel.drawHistory.length);
    notifyListeners();
  }

  void handlePanUpdate(ToolUpdateInput input){

    if(!_panTool.isActive) return;

    _lastDeviceKind = input.kind;
    _panTool.onToolUpdate(input, _viewModel.activeLayerId);
    _viewModel.forceCanvasRefresh();
    notifyListeners();
  }

  void handlePanEnd(ToolReleasedInput input){
    if(!_panTool.isActive) return;
    _lastDeviceKind = input.lastUsedDevice;
    _panTool.onToolEnd();
    notifyListeners();
  }

  void initializeTools({Type? initialTool}) {
    tools = {
      FreehandTool: FreehandTool(
        toolName: 'Freehand Tool',
        toolIcon: Icon(Icons.draw),
        defaultStrokePaint: Paint()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5, renderStroke: true,
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: _viewModel.camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser), defaultStrokePaint: Paint()..style = PaintingStyle.stroke..strokeWidth = 20,
      ),
      CircleTool: CircleTool(
        toolIcon: Icon(Icons.circle),
        toolName: 'Circle Tool',
        defaultStrokePaint: Paint()..style = PaintingStyle.stroke..strokeWidth = 5, defaultFillPaint: Paint()..color = Colors.grey, renderStroke: true, renderFill: true,
      ),
      RectangleTool: RectangleTool(
        toolName: 'Rectangle Tool',
        toolIcon: Icon(Icons.square), 
        defaultStrokePaint: Paint()
          ..color = Colors.black
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke, defaultFillPaint: Paint()..color = Colors.grey, renderStroke: true, renderFill: true,
      ),
      LineTool: LineTool(
        toolIcon: Icon(Icons.horizontal_rule),
        toolName: 'Line Tool',
        defaultStrokePaint: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..color = Colors.black, renderStroke: true,
      ),
      PathTool: PathTool(toolIcon: Icon(Icons.polyline),defaultFillPaint: Paint()..color = Colors.blue, toolName: 'Path Tool', defaultStrokePaint: Paint()..strokeWidth = 5..color = Colors.black..style = PaintingStyle.stroke..strokeJoin..strokeJoin = StrokeJoin.round, renderFill: true, renderStroke: true)
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
        _viewModel.executeCommand(finalCommand);
      }

      //To kill any tools that won't necessarily stop drawing when calling onToolEnd
      _currentTool.cancel();
    }

    _currentTool = targetTool;
    notifyListeners();
  }


  void disableDrawing() {
    // If a simple gesture tool is actively drawing, commit its current stroke safely
    inputHandlers[lastDeviceKind]?.disableInput();
    if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
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
