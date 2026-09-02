import 'dart:ui';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:flutter/material.dart';

class FreehandTool extends DrawTool {
  FreehandTool({required super.toolName, required super.toolIcon});

  @override
  void draw(Canvas canvas, DrawCommand drawCommand) {
    if (drawCommand.points.isEmpty) return;

    if (drawCommand.strokeSettings != null) {
      _drawIndividualLine(
        canvas,
        drawCommand.points,
        drawCommand.strokeSettings!,
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
  void onDrawEnd({
    required DrawCommand? activeCommand,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
  }) {
    if(activeCommand != null && activeCommand.points.isNotEmpty){
      drawHistory.add(activeCommand);

    layerDrawHistory[layerId] = [
      ...?layerDrawHistory[layerId],
      activeCommand

    ];
    }
  }

  @override
  DrawCommand? onDrawStart({
    required Offset startPoint,
    required Paint strokeSettings,
    required Paint fillSettings,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
  }) {
   return DrawCommand.data(
      toolName: toolName,
      layerId: layerId,
      points: [startPoint],
      strokeSettings: strokeSettings,
      fillSettings: fillSettings,
    );
  }

  @override
  DrawCommand? onUpdateTool({
    required DrawCommand activeCommand,
    required Offset newPoint,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required double gestureScale,
    required int pointerCount,
    required ToolMatrixPayload camera
    
  }) {
 return activeCommand.copyWith(
      points: [...activeCommand.points, newPoint],
    );
  }
}
