import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/domain/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/draw_tools/freehand_tool.dart';
import 'package:flutter/material.dart';
class PainterController extends ChangeNotifier {
  final List<DrawLayer> _layers = [DrawLayer(id: 'l_0', name: 'Layer 1')];
  
  // Your tool library stays static and lightweight
  final Map<String, DrawTool> tools = {
    'Freehand Tool': const FreehandTool(toolName: 'Freehand Tool', toolIcon: Icon(Icons.draw)),
  };

  late DrawTool _currentTool;
  DrawCommand? _activeCommand; // Centralized live tracking block
  int _activeLayerIndex = 0;

  // Active configurations used when launching new lines
  Color strokeColor = Colors.black;
  double strokeWidth = 5.0;

  PainterController() {
    _currentTool = tools.values.first;
  }

  // Getters
  DrawTool get currentTool => _currentTool;
  DrawCommand? get activeCommand => _activeCommand;
  List<DrawLayer> get layers => _layers;
  int get activeLayerIndex => _activeLayerIndex;

  void setTool(DrawTool newTool) {
    _currentTool = newTool;
    notifyListeners();
  }

  void startTool(Offset startPoint) {
    final strokeSettings = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillSettings = Paint();

    // The stateless tool tells the controller how to build the initial data structure
    _activeCommand = _currentTool.onDrawStart(startPoint, strokeSettings, fillSettings);
    notifyListeners();
  }

  void updateTool(Offset usePoint) {
    if (_activeCommand == null) return;
    
    // The stateless tool modifies the current command frame cleanly
    _activeCommand = _currentTool.onUpdateTool(_activeCommand!, usePoint);
    notifyListeners();
  }

  void endTool() {
    if (_activeCommand == null) return;

    final finalizedCommand = _currentTool.onDrawEnd(_activeCommand!);
    DrawLayer layer = _layers[_activeLayerIndex];
    
    // Save to history list immutably
    _layers[_activeLayerIndex] = layer.copyWith(
      layerDrawHistory: List<DrawCommand>.from(layer.layerDrawHistory)..add(finalizedCommand),
    );

    _activeCommand = null; // Clean up active tracking completely
    notifyListeners();
  }
}
