import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
  import 'dart:math';

import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();
abstract class DrawTool extends CanvasTool{

  DrawTool({required super.toolName, required super.toolIcon});

  DrawData? get activePreview;

  



// double distanceToSegment(Offset p, Offset p1, Offset p2) {
//   final double x = p.dx, y = p.dy;
//   final double x1 = p1.dx, y1 = p1.dy;
//   final double x2 = p2.dx, y2 = p2.dy;

//   final double dx = x2 - x1;
//   final double dy = y2 - y1;

//   // Segment is a single point
//   if (dx == 0 && dy == 0) {
//     return (p - p1).distanceSquared;
//   }

//   // Calculate projection factor t, clamped between 0.0 and 1.0
//   double t = ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
//   t = max(0.0, min(1.0, t));

//   // Find the exact closest point on the line segment
//   final double closestX = x1 + t * dx;
//   final double closestY = y1 + t * dy;

//   // Calculate distance squared to the target point
//   final double diffX = x - closestX;
//   final double diffY = y - closestY;
//   return diffX * diffX + diffY * diffY;
// }

}

abstract class StrokeToolType{
  Paint get strokePaint;
  bool get renderStroke;

  void updateStrokePaint(Paint updatedStrokePaint);

  void toggleRenderStroke(bool enabled);
}

abstract class FillToolType{
  Paint get fillPaint;
  bool get renderFill;

  void updateFillPaint(Paint updatedFillPaint);
  void toggleRenderFill(bool enabled);
}

