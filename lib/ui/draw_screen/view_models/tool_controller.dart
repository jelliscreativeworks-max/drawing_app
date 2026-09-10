import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:drawing_app/utils/history_consumer.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class ToolController extends ChangeNotifier {
  final DrawScreenViewModel _viewModel;

  Color activeColor = Colors.black;
  double activeStrokeWidth = 5.0;

  late final Map<Type, DrawTool> tools;
  late DrawTool _currentTool;

  DrawData? get activePreview => _currentTool.activePreview;

  ToolController({required DrawScreenViewModel viewModel})
    : _viewModel = viewModel {
      initializeTools();
    }

  DrawTool get currentTool => _currentTool;

  void initializeTools({Type? initialTool}){
tools = {
      FreehandTool: FreehandTool(
        toolName: 'Freehand Tool',
        toolIcon: Icon(Icons.draw),
        strokePaint: Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
        
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: _viewModel.camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser)
      ),
    };
    if(initialTool != null){
    _currentTool = tools.containsKey(initialTool) ? tools[initialTool]! : tools.values.first;
    } else {
      _currentTool = tools[PanTool]!;
    }
    // _currentTool =  tools[PanTool]!;
  }

  void selectTool<T extends DrawTool>() {
    final targetTool = tools[T];
    if (targetTool == null || targetTool == _currentTool) return;

    // clear its caches, and emit any final transformation commands before swapping!
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
  // --- New Type-Safe Scale Gestures Layer Interceptors ---

  void handleScaleStart(Offset screenFocalPoint) {
    if (_currentTool.isActive) return;

    // Anchor camera reference configurations before calculating adjustments
    _viewModel.camera.focalPointAtStart = screenFocalPoint;
    _viewModel.camera.scaleStart = _viewModel.camera.currentScale;

    final Offset worldPosition = _screenToWorld(screenFocalPoint);
    final Offset targetPosition = _currentTool is PanTool ? screenFocalPoint : worldPosition;

    if(_currentTool is HistoryConsumer){
      List<DrawData> drawHistory = _viewModel.getHistoryForLayer(_viewModel.activeLayerId);
      (_currentTool as HistoryConsumer).setHistorySnapshot(drawHistory);
    }

    _currentTool.onDrawStart(
      startPoint:  targetPosition,
      layerId:  _viewModel.activeLayerId,
      nextStrokeIndex:  _viewModel.drawHistory.length,
      color: activeColor,
      strokeWidth: activeStrokeWidth,
    );

    notifyListeners();
  }

  void handleScaleUpdate(Offset screenFocalPoint, double gestureScale) {
    if (!_currentTool.isActive) return;

    if (_currentTool is PanTool) {
      // 1. Capture and process real-time panning deltas using focal coordinates
      _currentTool.onUpdateTool(newPoint:  screenFocalPoint);

      // 2. 🟢 FIX: If the user pinches while the Pan tool is active, execute zoom adjustments!
      if (gestureScale != 1.0) {
        // Feed the anchor points and scale multiplier directly down into your ViewModel math
        _viewModel.handlePinchZoom(gestureScale);
      }
      
      _viewModel.forceCanvasRefresh();
    } else {
      // Process standard line sketching coordinate points 
      final Offset worldPosition = _screenToWorld(screenFocalPoint);
      _currentTool.onUpdateTool(newPoint: worldPosition);
      notifyListeners();
    }
  }

  void handleScaleEnd() {

    final command = _currentTool.onDrawEnd();
    notifyListeners();

    if (command != null) {
      _viewModel.executeCommand(command);
    }

    notifyListeners();
  }


  // ==========================================
  // --- COORDINATE MAPPING TRANSLATION ENGINE ---
  // ==========================================
  // ==========================================
  // --- COORDINATE MAPPING TRANSLATION ENGINE ---
  // ==========================================

  Offset _screenToWorld(Offset screenPoint) {
    final Matrix4 transformMatrix = _viewModel.camera.transform;
    
    // Invert the camera transformation matrix to reverse the painter's shift
    final Matrix4 inverted = Matrix4.copy(transformMatrix)..invert();
    
    // Cast the 2D offset into a 4D vector space calculation block
    final vm.Vector4 screenVector = vm.Vector4(screenPoint.dx, screenPoint.dy, 0.0, 1.0);
    final vm.Vector4 worldVector = inverted.transform(screenVector);
    
    return Offset(worldVector.x, worldVector.y);
  }


}

