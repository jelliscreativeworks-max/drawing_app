import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_layer/draw_layer.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/freehand_tool.dart';
import 'package:flutter/material.dart';
class PainterController extends ChangeNotifier {
  final List<DrawLayer> _layers = [DrawLayer(id: 'l_0', name: 'Layer 1')];


    final Map<String, List<DrawCommand>> _cachedLayerHistories = {
    'l_0': [],
  };
  
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

  PainterController({required List<DrawCommand> drawCommandHistory}) : _drawHistory = drawCommandHistory {
    _currentTool = tools.values.first;
  }
  final List<DrawCommand> _drawHistory;
  final List<DrawCommand> _drawRedoHistory = [];


  // Getters
  List<DrawCommand> get drawHistory => _drawHistory;
  List<DrawCommand> get redoHistory => _drawRedoHistory; 
  DrawTool get currentTool => _currentTool;
  DrawCommand? get activeCommand => _activeCommand;
  List<DrawLayer> get layers => _layers;
  int get activeLayerIndex => _activeLayerIndex;

  void setTool(DrawTool newTool) {
    _currentTool = newTool;
    notifyListeners();
  }

  void startTool(Offset startPoint) {

    // TODO: Change this
    final strokeSettings = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillSettings = Paint();

    _activeCommand = _currentTool.onDrawStart(startPoint, strokeSettings, fillSettings, layers[activeLayerIndex].id);
    notifyListeners();
  }

  void _rebuildCacheForLayer(String layerId) {
    _cachedLayerHistories[layerId] = _drawHistory.where((cmd) => cmd.layerId == layerId).toList();
  }

    // Filters the global timeline for a specific layer ID dynamically
  List<DrawCommand> getHistoryForLayer(String layerId) => _cachedLayerHistories[layerId] ?? const [];


  void updateTool(Offset usePoint) {
    if (_activeCommand == null) return;
    

    _activeCommand = _currentTool.onUpdateTool(_activeCommand!, usePoint);
    notifyListeners();
  }

  void endTool() {
    if (_activeCommand == null) return;

    final finalizedCommand = _currentTool.onDrawEnd(_activeCommand!);
    _drawHistory.add(finalizedCommand);
    _drawRedoHistory.clear();
    // Save to history list immutably
    final layerId = finalizedCommand.layerId;
    _cachedLayerHistories[layerId] = [...?_cachedLayerHistories[layerId], finalizedCommand];


    _activeCommand = null;
    notifyListeners();
  }

  void undo(){
    if(_drawHistory.isEmpty) return;

    final cmd = _drawHistory.removeLast();
    _drawRedoHistory.add(cmd);

        _rebuildCacheForLayer(cmd.layerId);
    
    notifyListeners();
  }

  void redo(){
    if(_drawRedoHistory.isEmpty) return;

    final cmd = _drawRedoHistory.removeLast();
    _drawHistory.add(cmd);

        _rebuildCacheForLayer(cmd.layerId);
    
    notifyListeners();
  }
}
