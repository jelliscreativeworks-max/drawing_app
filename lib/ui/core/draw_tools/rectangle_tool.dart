import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';


class RectangleTool extends DrawTool {
  bool _isDrawing = false;
  DrawData? _activeShape;

  RectangleTool({required super.toolName, required super.toolIcon, super.fillPaint, super.strokePaint});

  @override
  DrawData? get activePreview => _activeShape;

  @override
  void draw(Canvas canvas, DrawData drawData) {
    _drawRectangle(canvas, drawData);
  }

  void _drawRectangle(Canvas canvas, DrawData drawData){
        if(drawData.points.length == 4){
    final Rect rect = Rect.fromPoints(drawData.points.first, drawData.points[2]);
    if(drawData.strokeSettings != null) {canvas.drawRect(rect, drawData.strokeSettings!);}
    if(drawData.fillSettings != null){ canvas.drawRect(rect, drawData.fillSettings!);}
    }
  }

  @override
  bool get isActive => _isDrawing;

  @override
  CanvasCommand? onDrawEnd() {
    if(!_isDrawing || _activeShape == null) return null;

    _isDrawing = false;

    final completedRect = _activeShape;
    _activeShape = null;

    return DrawCommand(drawData: completedRect!);

  }

  @override
  void onDrawStart({
    required PointerDeviceKind deviceKind,
    required Offset startPoint,
    required String layerId,
    required int nextStrokeIndex,
    required Color color,
    required double strokeWidth,
  }) {
    _isDrawing = true;

    _activeShape = DrawData(layerId: layerId, toolName: toolName, index: nextStrokeIndex,fillSettings: fillPaint, strokeSettings: strokePaint, id: uuid.v4(), points: [startPoint]);
  }

  @override
  void onUpdateTool({
    required Offset newPoint,
    required double gestureScale,
    required PointerDeviceKind deviceKind,
  }) {
      if(!_isDrawing) return;
      final List<Offset> points = [
        _activeShape!.points.first, 
        Offset(newPoint.dx, _activeShape!.points.first.dy),
        newPoint,
        Offset(_activeShape!.points.first.dx, newPoint.dy)];
      _activeShape = _activeShape!.copyWith(points: points);
  }
}
