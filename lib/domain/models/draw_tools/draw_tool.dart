import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:flutter/material.dart';
  import 'dart:math';

class ToolMatrixPayload {
  Matrix4 transform;
  Offset panStartOrigin;
  double scaleStart;
  Offset focalPointAtStart;
  final double currentScale;

  ToolMatrixPayload({
    required this.transform,
    required this.panStartOrigin,
    required this.scaleStart,
    required this.focalPointAtStart,
    required this.currentScale,
  });
}

abstract class DrawTool {
  final String toolName;
  final Icon toolIcon;

  const DrawTool({required this.toolName, required this.toolIcon});

  bool get isNavigationTool => false;

  CanvasCommand? onDrawStart({
    required Offset startPoint,
    required Paint strokeSettings,
    required Paint fillSettings,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
    }
  );
  CanvasCommand? onUpdateTool({
    required CanvasCommand activeCommand,
    required Offset newPoint,
    required List<DrawCommand> drawHistory,
    required Map<String,List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera,
    required int pointerCount,
    required double gestureScale,
  });

  void onDrawEnd({
    required CanvasCommand? activeCommand,
    required String layerId,
    required List<DrawCommand> drawHistory,
    required List<CanvasCommand> undoHistory,
    required List<CanvasCommand> redoHistory,
    required Map<String, List<DrawCommand>> layerDrawHistory,
    required ToolMatrixPayload camera
  });

  void draw(Canvas canvas, CanvasCommand drawCommand);



double distanceToSegment(Offset p, Offset p1, Offset p2) {
  final double x = p.dx, y = p.dy;
  final double x1 = p1.dx, y1 = p1.dy;
  final double x2 = p2.dx, y2 = p2.dy;

  final double dx = x2 - x1;
  final double dy = y2 - y1;

  // Segment is a single point
  if (dx == 0 && dy == 0) {
    return (p - p1).distanceSquared;
  }

  // Calculate projection factor t, clamped between 0.0 and 1.0
  double t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
  t = max(0.0, min(1.0, t));

  // Find the exact closest point on the line segment
  final double closestX = x1 + t * dx;
  final double closestY = y1 + t * dy;

  // Calculate distance squared to the target point
  final double diffX = x - closestX;
  final double diffY = y - closestY;
  return diffX * diffX + diffY * diffY;
}

}
