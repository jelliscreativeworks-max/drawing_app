import 'dart:ui';

import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/core/commands/erase_draw_command.dart';

class EraseTool extends DrawTool {
  EraseTool({required super.toolName, required super.toolIcon, required List<DrawData> drawHistory}) : _drawHistory = drawHistory;

  final List<CanvasHistoryEntry> _erasedDrawData = [];
  final List<DrawData> _drawHistory;
  String _currentLayerId = '';
  int _currentIndex = 0;
  bool _isErasing = false;

  @override
  void draw(Canvas canvas, DrawData drawData) {}



    void _checkCollisions(Offset pointerPosition) {
    // Basic structural distance hit testing down the drawing array
    for (int i = 0; i < _drawHistory.length; i++) {
      final data = _drawHistory[i];
      
      // Optional: Only erase items on the currently active visible layer
      if (data.layerId != _currentLayerId) continue;

      for (Offset point in data.points) {
        if ((point - pointerPosition).distanceSquared <= 50.0) { // Hitbox threshold
          final alreadyCached = _erasedDrawData.any((e) => e.drawData == data);
          
          if (!alreadyCached) {
            _erasedDrawData.add(
              CanvasHistoryEntry(originalIndex: i, drawData: data),
            );
          }
          break; // Break outer point loop, move to next stroke
        }
      }
    }
  }


  @override
  void onDrawStart({required Offset startPoint, required String layerId, required int nextStrokeIndex, required Color color, required double strokeWidth}) {
    _isErasing = true;
    _currentLayerId = layerId;
    _currentIndex = nextStrokeIndex;
    _erasedDrawData.clear();

    _checkCollisions(startPoint);

  }

  @override
  void onUpdateTool({required Offset newPoint}) {
    if(!_isErasing) return;
    _checkCollisions(newPoint);
  }

    @override
  CanvasCommand? onDrawEnd() {
    if(!_isErasing || _erasedDrawData.isEmpty) return null;
    _isErasing = false;

    final eraseCommand = EraseDrawCommand(layerId: _currentLayerId, index: _currentIndex, erasedDrawData: List<CanvasHistoryEntry>.from(_erasedDrawData));

    _erasedDrawData.clear();
    return eraseCommand;
  }

  @override
  bool get isActive => _isErasing;

  @override
  // TODO: implement activePreview
  DrawData? get activePreview => throw UnimplementedError();


}
