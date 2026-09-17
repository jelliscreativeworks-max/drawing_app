import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart'; // Ensure correct path mapping

class MyPainter extends CustomPainter {
  final List<DrawData> drawHistory;
  final Matrix4 transform;
  final double canvasWidth;
  final double canvasHeight;
  final PointerDeviceKind deviceKind;
  

  final CanvasTool? activeTool;

  const MyPainter({
    required this.deviceKind,
    required this.drawHistory, 
    required this.transform,
    required this.canvasWidth,
    required this.canvasHeight,
    this.activeTool, // Optional parameter maintains perfect backward compatibility
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(transform.storage);

    final Rect artboardRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);
    canvas.clipRect(artboardRect, doAntiAlias: true);

    // Render whatever drawing sequence data stream is passed into the list loop
    if (drawHistory.isNotEmpty) {
      for (final DrawData data in drawHistory) {
        data.draw(canvas);
      }
    }

    // Allow tools to draw non-data UI decorators (like path node rings) over the lines
    // Pass the current matrix scale factor so sizes stay completely uniform when zooming
    if (activeTool != null) {
      final double currentScale = transform.getMaxScaleOnAxis();
      activeTool!.drawToolOverlay(canvas, deviceKind, currentScale);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return oldDelegate.drawHistory != drawHistory || 
           oldDelegate.transform != transform ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.canvasHeight != canvasHeight ||
           oldDelegate.activeTool != activeTool;
  }
}
