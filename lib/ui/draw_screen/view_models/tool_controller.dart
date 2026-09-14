import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ToolController extends ChangeNotifier {
  final DrawScreenViewModel _viewModel;

  // DEBUG
  ScaleStartDetails startDetails = ScaleStartDetails();
  ScaleUpdateDetails updateDetails = ScaleUpdateDetails();

  Color activeColor = Colors.black;
  double activeStrokeWidth = 5.0;

  final Set<int> _activePointerIds = {};
   Set<int> get activePointerIds => _activePointerIds;

  late final Map<Type, DrawTool> tools;
  late DrawTool _currentTool;
  bool _panToolOverrideActive = false;


  DrawData? get activePreview => _currentTool.activePreview;

  ToolController({required DrawScreenViewModel viewModel})
    : _viewModel = viewModel {
    initializeTools();
  }
  PointerDeviceKind get lastDeviceKind => _lastDeviceKind;
  PointerDeviceKind _lastDeviceKind = PointerDeviceKind.unknown;
  bool drawEnabled = true;

  DrawTool get currentTool => _currentTool;

  void initializeTools({Type? initialTool}) {
    tools = {
      FreehandTool: FreehandTool(
        toolName: 'Freehand Tool',
        toolIcon: Icon(Icons.draw),
        strokePaint: Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: _viewModel.camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser),
      ),
    };
    if (initialTool != null) {
      _currentTool = tools.containsKey(initialTool)
          ? tools[initialTool]!
          : tools.values.first;
    } else {
      _currentTool = tools[PanTool]!;
    }

  }

  void selectTool<T extends DrawTool>() {
    final targetTool = tools[T];
    if (targetTool == null || targetTool == _currentTool) return;

    // clear its caches, and emit any final transformation commands before swapping
    if (_currentTool.isActive) {
      final finalCommand = _currentTool.onDrawEnd();
      if (finalCommand != null) {
        _viewModel.executeCommand(finalCommand);
      }
    }

    _currentTool = targetTool;
    notifyListeners();
  }

  void updateColor(Color newColor) {
    activeColor = newColor;
    notifyListeners();
  }

  void updateStrokeWidth(double newWidth) {
    activeStrokeWidth = newWidth;
    notifyListeners();
  }

  void onPointerDown(PointerDownEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.add(event.pointer);
    _lastDeviceKind = event.kind;

    // Handle Middle Click Panning (Even if a drawing tool is active)
    if (event.buttons == kTertiaryButton) {
      _panToolOverrideActive = true;

      // End active drawing tools cleanly before shifting the viewport matrix
      if (_currentTool.isActive) {
        final command = _currentTool.onDrawEnd();
        if (command != null) _viewModel.executeCommand(command);
      }

      // Initialize the pan tool tracking variables cleanly
      tools[PanTool]!.onDrawStart(
        deviceKind: event.kind,
        startPoint: event.localPosition,
        layerId: _viewModel.activeLayerId,
        nextStrokeIndex: _viewModel.drawHistory.length,
        color: activeColor,
        strokeWidth: activeStrokeWidth,
      );
      notifyListeners();
      return;
    }

    // Touch Overrides (Two fingers or more triggers PanTool)
    if (_activePointerIds.length > 1 && _currentTool is! PanTool) {
      _panToolOverrideActive = true;
      final command = _currentTool.onDrawEnd();
      if (command != null) _viewModel.executeCommand(command);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (!drawEnabled) return;
    // Handle Middle Click drag tracking directly
    if (event.buttons == kTertiaryButton || _panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse) {
      final panTool = tools[PanTool] as PanTool;

      if (!panTool.isActive) {
        _panToolOverrideActive = true;
        panTool.onDrawStart(
          deviceKind: event.kind,
          startPoint: event.localPosition,
          layerId: _viewModel.activeLayerId,
          nextStrokeIndex: _viewModel.drawHistory.length,
          color: activeColor,
          strokeWidth: activeStrokeWidth,
        );
      }

      // Safe update execution directly via the move position delta
      panTool.onUpdateTool(
        newPoint: event.localPosition,
        gestureScale: 1.0,
        deviceKind: event.kind,
      );
      _viewModel.forceCanvasRefresh();
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    // Cleanly close down middle-mouse pan action
    if (_panToolOverrideActive && _lastDeviceKind == PointerDeviceKind.mouse) {
      tools[PanTool]!.onDrawEnd();
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);
    
    if (_panToolOverrideActive) {
      tools[PanTool]!.onDrawEnd();
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }


void onPointerPanZoomStart(PointerPanZoomStartEvent event) {
  if (!drawEnabled) return;
  
  // 1. Log that we are actively on a trackpad interaction loop
  _lastDeviceKind = PointerDeviceKind.trackpad;

  // 2. Continuously sync the camera focal point to the trackpad's hover location
  _viewModel.camera.focalPointAtStart = event.localPosition;
  _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
  _viewModel.camera.previousGestureScale = 1.0;
  
  // 3. Keep world pivot calculation accurate for your tools
  _viewModel.camera.worldPivotAtStart = screenToWorld(event.localPosition);

  // Trigger your PanTool initialization hook cleanly
  tools[PanTool]!.onDrawStart(
    deviceKind: PointerDeviceKind.trackpad,
    startPoint: event.localPosition,
    layerId: _viewModel.activeLayerId,
    nextStrokeIndex: _viewModel.drawHistory.length,
    color: activeColor,
    strokeWidth: activeStrokeWidth,
  );
}
void onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
  if (!drawEnabled) return;

  _viewModel.camera.focalPointAtStart = event.localPosition;

  tools[PanTool]!.onUpdateTool(
    newPoint: event.localPanDelta, // Pure tracking delta
    gestureScale: event.scale, 
    deviceKind: PointerDeviceKind.trackpad,
  );
  
  _viewModel.forceCanvasRefresh();
}


  // 🟢 Handles Trackpad Touch-Lift Cleanup
  void onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (!drawEnabled) return;
    _activePointerIds.remove(event.pointer);

    if (_panToolOverrideActive) {
      tools[PanTool]!.onDrawEnd();
      _panToolOverrideActive = false;
      notifyListeners();
    }
  }


  void handleScaleStart(ScaleStartDetails details, PointerDeviceKind device) {
    if(!drawEnabled) return;

    if (device == PointerDeviceKind.trackpad || _lastDeviceKind == PointerDeviceKind.trackpad) return;
  
  
    startDetails = details;
    
    if (details.pointerCount > 1 && _currentTool is! PanTool) {
      _panToolOverrideActive = true;
      if (_currentTool.isActive) {
        CanvasCommand? command = _currentTool.onDrawEnd();
        if (command != null) _viewModel.executeCommand(command);
      }
    }

    if (_currentTool.isActive && !_panToolOverrideActive) return;
    _viewModel.camera.focalPointAtStart = details.localFocalPoint;
    _viewModel.camera.scaleStart = _viewModel.camera.currentScale;
    _viewModel.camera.previousGestureScale = 1.0;

    _viewModel.camera.worldPivotAtStart = screenToWorld(details.localFocalPoint);

    final Offset targetPosition = _currentTool is PanTool || _panToolOverrideActive
        ? details.localFocalPoint
        : _viewModel.camera.worldPivotAtStart;


    if (_currentTool is HistoryConsumer && _panToolOverrideActive == false) {
      List<DrawData> drawHistory = _viewModel.getHistoryForLayer(_viewModel.activeLayerId);
      (_currentTool as HistoryConsumer).setHistorySnapshot(drawHistory);
    }

    if(_panToolOverrideActive && _currentTool is! PanTool){

      tools[PanTool]!.onDrawStart(
        deviceKind: device,
        startPoint: targetPosition,
        layerId: _viewModel.activeLayerId,
        nextStrokeIndex: _viewModel.drawHistory.length,
        color: activeColor,
        strokeWidth: activeStrokeWidth,
      );
    } else{
      _currentTool.onDrawStart(
        deviceKind: device,
        startPoint: targetPosition,
        layerId: _viewModel.activeLayerId,
        nextStrokeIndex: _viewModel.drawHistory.length,
        color: activeColor,
        strokeWidth: activeStrokeWidth,
      );
    }

    notifyListeners();
  }

  void handleScaleUpdate(ScaleUpdateDetails details) {
    if (!drawEnabled) return;

    if (_lastDeviceKind == PointerDeviceKind.trackpad) return;

    updateDetails = details;
    if (!_currentTool.isActive && _panToolOverrideActive == false) return;

    if (_currentTool is PanTool || _panToolOverrideActive) {
      if (_currentTool is PanTool) {
        _currentTool.onUpdateTool(
          newPoint: details.localFocalPoint, 
          gestureScale: details.scale, 
          deviceKind: _lastDeviceKind,
        );
      } else {
        tools[PanTool]!.onUpdateTool(
          newPoint: details.localFocalPoint, 
          gestureScale: details.scale, 
          deviceKind: _lastDeviceKind,
        );
      }
      _viewModel.forceCanvasRefresh();
    } else {
      final Offset worldPosition = screenToWorld(details.localFocalPoint);
      _currentTool.onUpdateTool(
        newPoint: worldPosition, 
        gestureScale: details.scale, 
        deviceKind: _lastDeviceKind,
      );
      notifyListeners();
    }
  }

  void handleScaleEnd() {
    if(!drawEnabled) return;
 

    if(_panToolOverrideActive){
      tools[PanTool]!.onDrawEnd();
      _panToolOverrideActive = false;
      _activePointerIds.clear();
      notifyListeners();
    }
    else if(_currentTool.isActive){
      final command = _currentTool.onDrawEnd();
      if (command != null) {
        _viewModel.executeCommand(command);
      }
      notifyListeners();
    }
  }

  void disableDrawing(){
    handleScaleEnd();
    _panToolOverrideActive = false;
    drawEnabled = false;
    _activePointerIds.clear();
    notifyListeners();
  }

  void enableDrawing(){
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
