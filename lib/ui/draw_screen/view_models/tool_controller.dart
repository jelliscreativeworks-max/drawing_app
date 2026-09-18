import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/circle_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/line_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/path_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/rectangle_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ToolController extends ChangeNotifier {
  final DrawScreenViewModel _viewModel;

  // DEBUG
  ScaleStartDetails? startDetails;
  ScaleUpdateDetails? updateDetails;

  final Set<int> _activePointerIds = {};
  Set<int> get activePointerIds => _activePointerIds;


  Offset _lastTrackedScreenPoint = Offset.zero;


  late final Map<Type, CanvasTool> tools;
  late CanvasTool _currentTool;
  bool _panToolOverrideActive = false;

  DrawData? get activePreview => _currentTool is DrawTool ? (_currentTool as DrawTool).activePreview : null;

  ToolController({required DrawScreenViewModel viewModel})
    : _viewModel = viewModel {
    initializeTools();
  }
  PointerDeviceKind get lastDeviceKind => _lastDeviceKind;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;
  bool drawEnabled = true;

  CanvasTool get currentTool => _currentTool;

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

  /// On mouse/touch down, does not trigger from a [PointerDownEvent.trackpad]. Runs before [onHandleScaleStart] is called.
  /// Adds pointer ids to a set for tracking unique pointers and serves as the initilization point for tools
    void onPointerDown(PointerDownEvent event) {
    
    
    if (event.kind == PointerDeviceKind.touch || event.kind == PointerDeviceKind.stylus) {
      drawEnabled = true; 
    }

    if (!drawEnabled) return;
    _activePointerIds.add(event.pointer);
    _lastDeviceKind = event.kind;
    _lastTrackedScreenPoint = event.localPosition;

    final ToolStartFrame frame = ToolStartFrame.compute(
      deviceKind: event.kind,
      rawScreenPoint: event.localPosition,
      layerId: _viewModel.activeLayerId,
      strokeIndex: _viewModel.drawHistory.length,
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );

    // Handle Middle Click Panning (Viewport override)
    if (event.buttons == kTertiaryButton) {
      _panToolOverrideActive = true;
      if (_currentTool.isActive) {
        final command = _currentTool.onToolEnd();
        if (command != null) _viewModel.executeCommand(command);
      }
      tools[PanTool]!.onToolStart(frame);
      notifyListeners();
      return;
    }

    // Touch Overrides (Two fingers or more triggers PanTool)
    if (_activePointerIds.length > 1 && _currentTool is! PanTool) {
      _panToolOverrideActive = true;
      if (_currentTool.isActive) {
        final command = _currentTool.onToolEnd();
        if (command != null) _viewModel.executeCommand(command);
      }
      tools[PanTool]!.onToolStart(frame);
      notifyListeners();
      return;
    }

    // Initialize drawing workspace cleanly
    if (!_panToolOverrideActive) {
      _currentTool.onToolStart(frame);
      notifyListeners();
    }
  }
  void onPointerMove(PointerMoveEvent event) {
    if (!drawEnabled) return;

    // Handle Middle Click drag tracking directly
    if (event.buttons == kTertiaryButton ||
        (_panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse)) {
      final panTool = tools[PanTool] as PanTool;

      if (!panTool.isActive) {
        _panToolOverrideActive = true;
        
        final ToolStartFrame startFrame = ToolStartFrame.compute(
          deviceKind: event.kind,
          rawScreenPoint: event.localPosition,
          layerId: _viewModel.activeLayerId,
          strokeIndex: _viewModel.drawHistory.length,
          screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
        );
        panTool.onToolStart(startFrame);
      }

      final ToolUpdateFrame updateFrame = ToolUpdateFrame.computeUpdate(
        deviceKind: event.kind,
        currentScreenPoint: event.localPosition,
        currentScale: 1.0,
        layerId: _viewModel.activeLayerId,
        priorScreenPoint: _lastTrackedScreenPoint,
        screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
      );

      panTool.onToolUpdate(updateFrame);
      _viewModel.forceCanvasRefresh();
    } else {
      // Route standard pointer movements to your active drawing tool
      if (_currentTool.isActive && !_panToolOverrideActive) {
        final ToolUpdateFrame updateFrame = ToolUpdateFrame.computeUpdate(
          deviceKind: event.kind,
          currentScreenPoint: event.localPosition,
          currentScale: 1.0,
          layerId: _viewModel.activeLayerId,
          priorScreenPoint: _lastTrackedScreenPoint,
          screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
        );

        _currentTool.onToolUpdate(updateFrame);
        notifyListeners();
      }
    }

    // Keep subsequent frame deltas perfectly consecutive
    _lastTrackedScreenPoint = event.localPosition;
  }


  void onPointerUp(PointerUpEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    // Cleanly close down middle-mouse pan action
    if (_panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse) {
      final panTool = tools[PanTool]!;
      if (panTool.isActive) {
        final command = panTool.onToolEnd();
        if (command != null) _viewModel.executeCommand(command);
      }
      _panToolOverrideActive = false;
      _currentTool.onPanOverrideEnd();
      notifyListeners();
    } else {
      // Clean up standard single-pointer drawing gestures safely on pointer up
      if (_currentTool.isActive) {
        final command = _currentTool.onToolEnd();
        if (command != null) {
          _viewModel.executeCommand(command);
        }
        notifyListeners();
      }
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    final panTool = tools[PanTool]!;
    if (panTool.isActive) {
      final command = panTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }

    if (_panToolOverrideActive) {
      _panToolOverrideActive = false;
      _currentTool.onPanOverrideEnd();
      notifyListeners();
    } else {
      if (_currentTool.isActive) {
        final command = _currentTool.onToolEnd();
        if (command != null) _viewModel.executeCommand(command);
        notifyListeners();
      }
    }
  }


  void onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (!drawEnabled) return;

    _lastDeviceKind = PointerDeviceKind.trackpad;

    _viewModel.camera.focalPointAtStart = event.localPosition;
    _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
    _viewModel.camera.previousGestureScale = 1.0;
    _viewModel.camera.worldPivotAtStart = screenToWorld(event.localPosition);

    _lastTrackedScreenPoint = event.localPosition;

    final ToolStartFrame frame = ToolStartFrame.compute(
      deviceKind: event.kind,
      rawScreenPoint: event.localPosition,
      layerId: _viewModel.activeLayerId,
      strokeIndex: _viewModel.drawHistory.length,
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );

    tools[PanTool]!.onToolStart(frame);
  }

  void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!drawEnabled) return;

    _viewModel.camera.focalPointAtStart = event.localPosition;

    final ToolUpdateFrame frame = ToolUpdateFrame(
      pointerDeviceKind: event.kind,
      rawScale: event.scale,
      activeLayerId: _viewModel.activeLayerId,
      delta: Offset.zero, 
      points: (
        screen: event.localPanDelta, 
        world: screenToWorld(event.localPosition),
      ),
    );

    tools[PanTool]!.onToolUpdate(frame);
    _viewModel.forceCanvasRefresh();
  }

  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    final panTool = tools[PanTool]!;
    if (panTool.isActive) {
      final command = panTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }
    
    _panToolOverrideActive = false;
    _currentTool.onPanOverrideEnd();
    notifyListeners();
  }




  void handleScaleUpdate(ScaleUpdateDetails details) {
  if (!drawEnabled) return;
  if (_lastDeviceKind == PointerDeviceKind.trackpad) return;

  updateDetails = details;
  if (!_currentTool.isActive && !_panToolOverrideActive) return;

  final ToolUpdateFrame frame = ToolUpdateFrame.computeUpdate(
    deviceKind: _lastDeviceKind,
    currentScreenPoint: details.localFocalPoint,
    currentScale: details.scale,
    layerId: _viewModel.activeLayerId,
    priorScreenPoint: _lastTrackedScreenPoint,
    screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
  );

  if (_currentTool is PanTool || _panToolOverrideActive) {
    if (_currentTool is PanTool) {
      _currentTool.onToolUpdate(frame);
    } else {
      tools[PanTool]!.onToolUpdate(frame);
    }
    _viewModel.forceCanvasRefresh();
  } else {
    _currentTool.onToolUpdate(frame);
    notifyListeners();
  }

  _lastTrackedScreenPoint = details.localFocalPoint;
}
 
void handleScaleStart(ScaleStartDetails details, PointerDeviceKind device) {
  if (!drawEnabled) return;
  if (device == PointerDeviceKind.trackpad || _lastDeviceKind == PointerDeviceKind.trackpad) return;

  startDetails = details;
  _lastDeviceKind = device;

  // 1. Triggered strictly during an intentional multi-finger touch pan/zoom layout shift
  if (details.pointerCount > 1 && _currentTool is! PanTool) {
    _panToolOverrideActive = true;
    
    if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }

    _currentTool.onPanOverrideStart();
  }

  // 2. Synchronize Viewport Matrix Camera Properties
  _viewModel.camera.focalPointAtStart = details.localFocalPoint;
  _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
  _viewModel.camera.previousGestureScale = 1.0;
  _viewModel.camera.worldPivotAtStart = screenToWorld(details.localFocalPoint);
  _lastTrackedScreenPoint = details.localFocalPoint;

  if (_currentTool is HistoryConsumer && !_panToolOverrideActive) {
    List<DrawData> drawHistory = _viewModel.getHistoryForLayer(_viewModel.activeLayerId);
    (_currentTool as HistoryConsumer).setHistorySnapshot(drawHistory);
  }

  // 3. ONLY route start frames to PanTool matrix layers here
  if (_panToolOverrideActive) {
    final ToolStartFrame frame = ToolStartFrame.compute(
      deviceKind: device,
      rawScreenPoint: details.localFocalPoint,
      layerId: _viewModel.activeLayerId,
      strokeIndex: _viewModel.drawHistory.length,
      screenToWorldConverter: (screenPoint) => screenToWorld(screenPoint),
    );
    tools[PanTool]!.onToolStart(frame);
    notifyListeners();
  }
}

void handleScaleEnd() {
  if (!drawEnabled) return;
  if (_lastDeviceKind == PointerDeviceKind.trackpad) return;

  if (_panToolOverrideActive) {
    if (_activePointerIds.isNotEmpty) {
      notifyListeners();
      return;
    }
    
    final panTool = tools[PanTool]!;
    if (panTool.isActive) {
      final command = panTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }
    
    _panToolOverrideActive = false;
    _currentTool.onPanOverrideEnd();
    notifyListeners();
  }
}



  void disableDrawing() {
    // If a simple gesture tool is actively drawing, commit its current stroke safely
    if (_currentTool.isActive) {
      final command = _currentTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }

    // Hard-cancel the active drawing tool context
    // This explicitly flushes multi-stroke coordinate arrays (like PathTool) 
    // to prevent ghost paths when drawing is later re-enabled
    _currentTool.cancel();

    // Cleanly tear down any active temporal viewport pan matrix loops
    final panTool = tools[PanTool]!;
    if (panTool.isActive) {
      final command = panTool.onToolEnd();
      if (command != null) _viewModel.executeCommand(command);
    }

    // Force reset all environmental gesture variables
    _panToolOverrideActive = false;
    drawEnabled = false;
    _activePointerIds.clear();
    
    // Clear out stored gesture history objects to prevent stale tracking updates
    updateDetails = null;
    startDetails = null;

    notifyListeners();
  }

  void enableDrawing(PointerEnterEvent event) {
    // Force clear tracking arrays to prevent stale pointer data from corrupting inputs
    _activePointerIds.clear();
    _panToolOverrideActive = false;
    
    // Clear input gesture details cache completely
    startDetails = null;
    updateDetails = null;

    if(event.kind == PointerDeviceKind.touch){
      _activePointerIds.add(event.pointer);
    }

    // Open the drawing state gates safely
    drawEnabled = true;
    
    notifyListeners();
  }


  Offset screenToWorld(Offset screenPoint) {
    final Matrix4 transformMatrix = _viewModel.camera.transform;

    // Invert the camera transformation matrix to reverse the painter's shift
    final Matrix4 inverted = Matrix4.copy(transformMatrix)..invert();

    // Cast the 2D offset into a 4D vector space calculation block
    final vm.Vector4 screenVector = vm.Vector4(
      screenPoint.dx,
      screenPoint.dy,
      0.0,
      1.0,
    );
    final vm.Vector4 worldVector = inverted.transform(screenVector);

    return Offset(worldVector.x, worldVector.y);
  }
}
