import 'dart:ui';

import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class CircleTool extends DrawTool{
  bool _isDrawing = false;
  DrawData? _circlePreview;

  CircleTool({required super.toolName, required super.toolIcon, super.fillPaint});

  @override
  // TODO: implement activePreview
  DrawData? get activePreview => _circlePreview;

  @override
  void draw(Canvas canvas, DrawData drawData) {
    _drawCircle(canvas, drawData);
  }

  void _drawCircle(Canvas canvas, DrawData drawData){
    if(drawData.fillSettings != null && drawData.points.length == 2){

      final Offset center = drawData.points[0];
      final double radius = drawData.points[1].dx;
  
      canvas.drawCircle(center, radius, drawData.fillSettings!);
    }
  }

  @override
  bool get isActive => _isDrawing;

  @override
  CanvasCommand? onDrawEnd() {
    if(!_isDrawing || _circlePreview == null) return null;

    _isDrawing = false;

    final completedRect = _circlePreview;
    _circlePreview = null;

    return DrawCommand(drawData: completedRect!);

  }

  @override
  void onDrawStart({required PointerDeviceKind deviceKind, required Offset startPoint, required String layerId, required int nextStrokeIndex, required Color color, required double strokeWidth}) {
    _isDrawing = true;
    _circlePreview = DrawData(layerId: layerId, toolName: toolName, fillSettings: fillPaint, index: nextStrokeIndex, id: uuid.v4(), points: [startPoint]);
  }

  @override
  void onUpdateTool({required Offset newPoint, required double gestureScale, required PointerDeviceKind deviceKind}) {
    if(!_isDrawing) return;

      final Offset center = _circlePreview!.points[0];  
      final double radius = (newPoint - center).distance;

      List<Offset> points = [_circlePreview!.points[0], Offset(radius, 0)];
      _circlePreview = _circlePreview!.copyWith(points: points);

  }
}