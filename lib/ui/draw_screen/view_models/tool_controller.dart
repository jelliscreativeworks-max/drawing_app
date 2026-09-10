import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/erase_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/freehand_tool.dart';
import 'package:drawing_app/ui/core/draw_tools/pan_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
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
      ),
      PanTool: PanTool(
        toolName: 'Pan Tool',
        toolIcon: Icon(Icons.pan_tool),
        camera: _viewModel.camera,
      ),
      EraseTool: EraseTool(
        toolName: 'Erase Tool',
        toolIcon: Icon(Symbols.ink_eraser),
        drawHistory: _viewModel.drawHistory,
      ),
    };
    if(initialTool != null){
    _currentTool = tools.containsKey(initialTool) ? tools[initialTool]! : tools.values.first;
    } else {
      _currentTool = tools[PanTool]!;
    }
    // _currentTool =  tools[PanTool]!;
  }

  void selectTool<T extends DrawTool>(){
    if(tools.containsKey(T) && _currentTool.runtimeType != T){
      _currentTool = tools[T]!;
      notifyListeners();
    }
  }

  void updateColor(Color newColor) {
    activeColor = newColor;
    notifyListeners();
  }

  void updateStrokeWidth(double newWidth) {
    activeStrokeWidth = newWidth;
    notifyListeners();
  }

  void handlePointerDown(Offset localScreenPosition) {
    if (_currentTool.isActive) return;

    // FIX: Convert screen touch position into a pristine canvas world point!
    final Offset worldPosition = _screenToWorld(localScreenPosition);

    _currentTool.onDrawStart(
       // Pass world position instead of raw screen coordinates!
      layerId:  _viewModel.activeLayerId,
      startPoint: _currentTool is PanTool ? localScreenPosition : worldPosition,
      nextStrokeIndex: _viewModel.drawHistory.length,
      color: activeColor,
      strokeWidth: activeStrokeWidth,
    );
    notifyListeners();
  }

  void handlePointerMove(Offset localScreenPosition) {
    if (_currentTool.isActive) return;

    if (_currentTool is PanTool) {
      // Navigational tools process raw screen deltas directly, so pass raw position
      _currentTool.onUpdateTool(newPoint: localScreenPosition);
      _viewModel.forceCanvasRefresh();
    } else {
      // Drawing/Erasing tools require accurate canvas world alignment space map coordinates
      final Offset worldPosition = _screenToWorld(localScreenPosition);
      _currentTool.onUpdateTool(newPoint: worldPosition);
      notifyListeners();
    }
  }

  void handlePointerUp() {
    final CanvasCommand? producedCommand = _currentTool.onDrawEnd();
    
    if (producedCommand != null) {
      // Safely dispatch the concrete mutation block back into the timeline engine
      _viewModel.executeCommand(producedCommand);
    }
  }

  // ==========================================
  // --- COORDINATE MAPPING TRANSLATION ENGINE ---
  // ==========================================
  // ==========================================
  // --- COORDINATE MAPPING TRANSLATION ENGINE ---
  // ==========================================

  /// Translates a physical screen touch position into a real canvas world coordinate,
  /// factoring in all active scale expansions and panning transformations.
  Offset _screenToWorld(Offset screenPoint) {
    final Matrix4 transformMatrix = _viewModel.camera.transform;
    
    // 1. Create a clean deep copy of the camera matrix and mathematically invert it
    final Matrix4 inverted = Matrix4.copy(transformMatrix)..invert();
    
    // 2. Cast the 2D Offset into a 4D Vector space computation block
    final vm.Vector4 screenVector = vm.Vector4(screenPoint.dx, screenPoint.dy, 0.0, 1.0);
    final vm.Vector4 worldVector = inverted.transform(screenVector);
    
    // 3. Extract the normalized world coordinates back out cleanly
    return Offset(worldVector.x, worldVector.y);
  }


}

