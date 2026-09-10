import 'dart:ui';
import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/commands/draw_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
class FreehandTool extends DrawTool {
  DrawData? _activeStroke;
  bool _isDrawing = false;



  FreehandTool({required super.toolName, required super.toolIcon, super.fillPaint, super.strokePaint});

  @override
  void draw(Canvas canvas, DrawData drawData) {
    if (drawData.points.isEmpty) return;

    if (drawData.strokeSettings != null) {
      _drawIndividualLine(
        canvas,
        drawData.points,
        drawData.strokeSettings!,
      );
    }
  }

  

  void _drawIndividualLine(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length == 1) {
      canvas.drawPoints(PointMode.points, points, paint);
    } else {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  CanvasCommand? onDrawEnd() {
    if(!_isDrawing || _activeStroke == null) return null;

    _isDrawing = false;

    final completedStroke = _activeStroke;
    _activeStroke = null;

    return DrawCommand(drawData: completedStroke!);

  }

  @override
  void onDrawStart({required Offset startPoint, required String layerId, required int nextStrokeIndex, required Color color, required double strokeWidth}) {
    _isDrawing = true;

    _activeStroke = DrawData(layerId: layerId, toolName: toolName,id: uuid.v4(),  index: nextStrokeIndex, points: [startPoint], strokeSettings: strokePaint);

  }

  @override
  void onUpdateTool({required Offset newPoint}) {
    if(!_isDrawing) return;
    final updatedPoints = List<Offset>.from(_activeStroke!.points)..add(newPoint);
    _activeStroke =  _activeStroke!.copyWith(points: updatedPoints);

  }

  @override
  bool get isActive => _isDrawing;

  @override
  DrawData? get activePreview => _activeStroke;



}
