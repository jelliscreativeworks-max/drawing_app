import 'dart:ui' as ui;
import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/ui/draw_screen/view_models/draw_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:units_converter/properties/area.dart';
import 'package:units_converter/units_converter.dart';

class MyPainter extends CustomPainter {
  final List<DrawCommand> drawHistory;
  final Map<String, DrawTool> drawTools;
  final DrawCommand? activeCommand; 
  
  // 1. INJECT CAMERA TRANSFORM AND ARTBOARD SIZES FROM VIEWMODEL
  final Matrix4 transform;
  final double canvasWidth;
  final double canvasHeight;

  // final double gridUnitSize;

  MyPainter({
    required this.drawHistory, 
    required this.drawTools, 
    required this.activeCommand,
    required this.transform,
    required this.canvasWidth,
    required this.canvasHeight,
    
  });

  @override
  void paint(Canvas canvas, Size size) {
  
    // Save the graphics state configuration before applying camera mutations
    canvas.save();
    
    // 2. THE CANVASKIT CORE: Apply the view model zoom/pan matrix directly to the canvas buffer!
    canvas.transform(transform.storage);

    // Define the rigid bounding box dimensions of your paper sheet
    final Rect artboardRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);

    // // 3. RENDER THE PHYSICAL ARTBOARD SHEET BACKGROUND WITH A DROP SHADOW
    // final Paint shadowPaint = Paint()
    //   ..color = Colors.black.withOpacity(0.25)
    //   ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    // // Draw the shadow shifted slightly down and to the right
    // canvas.drawRect(artboardRect.shift(const Offset(4, 4)), shadowPaint);
    // // Draw the pure white paper workspace surface
    // final Paint paperPaint = Paint()..color = Colors.transparent;
    // final Paint gridPaint = Paint()
    // ..style = PaintingStyle.fill
    // ..shader = 
    // canvas.drawRect(artboardRect, paperPaint);
    // canvas.drawRect(artboardRect, 

    // 4. HARDWARE-CLIP ANYTHING PAST THE EXPANDABLE ARTBOARD LIMITS
    // This stops lines from spilling over onto your workspace background!
    canvas.clipRect(artboardRect);

    // 5. Draw completed historical entries sequentially
    for (DrawCommand command in drawHistory) {
      final tool = drawTools[command.toolName];
      if (tool != null) {
        command.draw(canvas, tool);
      }
    }

    // 6. Draw the live brush stroke path previews in real-time
    if (activeCommand != null) {
      final tool = drawTools[activeCommand!.toolName];
      if (tool != null) {
        activeCommand!.draw(canvas, tool);
      }
    }

    // Restore the canvas pipeline back to standard system constraints
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    // Optimize redraw passes: block paint loops unless a structural change occurs
    return oldDelegate.drawHistory != drawHistory || 
           oldDelegate.activeCommand != activeCommand ||
           oldDelegate.transform != transform ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.canvasHeight != canvasHeight;
  }
}
