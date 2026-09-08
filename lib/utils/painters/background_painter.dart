import 'dart:typed_data';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final double opacity;
  final double lineThickness;
  final double cellSize; // The fixed size of each cell in absolute canvas coordinates (e.g., 40.0 units)

  final double canvasWidth;
  final double canvasHeight;
  final Matrix4 transform; // Passed cleanly from drawScreenViewModel.transform

  BackgroundPainter({
    required this.transform,
    required this.canvasHeight,
    required this.canvasWidth,
    this.cellSize = 40.0, 
    this.lineThickness = 1.0,
    this.opacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    // 1. Apply the camera matrix natively to the canvas state.
    // Panning, zooming, and focal points are now handled perfectly by Flutter.
    canvas.transform(transform.storage);

    // 2. Bound the grid perfectly to the artboard boundaries (matching MyPainter exactly)
    final Rect artboardRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);

    final Paint backgroundPaint = Paint()..color = DrawScreenViewModel.canvasBackgroundColor;

    canvas.drawRect(artboardRect, backgroundPaint);



    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.transform != transform ||
           oldDelegate.canvasHeight != canvasHeight ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.opacity != opacity ||
           oldDelegate.cellSize != cellSize ||
           oldDelegate.lineThickness != lineThickness;
  }
}
