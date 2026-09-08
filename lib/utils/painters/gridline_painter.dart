import 'dart:typed_data';
import 'package:flutter/material.dart';

class GridlinePainter extends CustomPainter {
  final double opacity;
  final double lineThickness;
  final double cellSize; // The fixed size of each cell in absolute canvas coordinates (e.g., 40.0 units)

  final double canvasWidth;
  final double canvasHeight;
  final Matrix4 transform; // Passed cleanly from drawScreenViewModel.transform

  GridlinePainter({
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
    canvas.clipRect(artboardRect);

    // 3. Extract the zoom scale factor from the matrix
    final double zoomScale = transform.getMaxScaleOnAxis();

    // 4. Set up the line paint.
    // We divide the lineThickness by zoomScale so that the grid lines themselves 
    // stay exactly 1 physical screen pixel thick on your device glass when you zoom in/out,
    // preventing them from looking fat or muddy when highly magnified.
    final Paint linePaint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..strokeWidth = lineThickness / zoomScale 
      ..style = PaintingStyle.stroke;

    // 5. Draw Vertical Grid Lines across your absolute canvas width bounds
    // The number of cells is strictly finite, determined by (canvasWidth / cellSize)
    for (double x = 0; x <= canvasWidth; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, canvasHeight), linePaint);
    }

    // 6. Draw Horizontal Grid Lines across your absolute canvas height bounds
    for (double y = 0; y <= canvasHeight; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(canvasWidth, y), linePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GridlinePainter oldDelegate) {
    return oldDelegate.transform != transform ||
           oldDelegate.canvasHeight != canvasHeight ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.opacity != opacity ||
           oldDelegate.cellSize != cellSize ||
           oldDelegate.lineThickness != lineThickness;
  }
}
