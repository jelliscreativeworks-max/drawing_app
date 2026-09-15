import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class LineTool extends DrawTool{
  bool _isDrawing = false;
  DrawData? _activeLine;

  LineTool({required super.toolName, required super.toolIcon, super.strokePaint});

  @override
  DrawData? get activePreview => _activeLine;

  @override
  void draw(Canvas canvas, DrawData drawData) {

    if(drawData.points.length != 2 || drawData.strokeSettings == null) return;

    _drawLine(canvas, drawData);
  }

  void _drawLine(Canvas canvas, DrawData data){
    canvas.drawLine(data.points[0], data.points[1], data.strokeSettings!);
  }

  @override
  bool get isActive => _isDrawing;

 @override
  CanvasCommand? onDrawEnd() {
    if(!_isDrawing || _activeLine == null) return null;

    _isDrawing = false;

    final completedLine = _activeLine;
    _activeLine = null;

    return DrawCommand(drawData: completedLine!);

  }

  @override
  void onDrawStart({required PointerDeviceKind deviceKind, required Offset startPoint, required String layerId, required int nextStrokeIndex, required Color color, required double strokeWidth}) {
    _isDrawing = true;
    _activeLine = DrawData(layerId: layerId, toolName: toolName, index: nextStrokeIndex, strokeSettings: strokePaint, id: uuid.v4(), points: [startPoint]);
  }

  @override
  void onUpdateTool({required Offset newPoint, required double gestureScale, required PointerDeviceKind deviceKind}) {
    if(!_isDrawing) return;

    final startPoint = _activeLine!.points[0];
    final endPoint = newPoint;

    final List<Offset> newPoints = [startPoint,endPoint];
    _activeLine = _activeLine!.copyWith(points: newPoints);
  }
  
}