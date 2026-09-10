import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';

class MyPainter extends CustomPainter {
  /// A pre-filtered vector timeline belonging exclusively to this isolated sheet layer.
  final List<DrawData> drawHistory;

  /// 🟢 FIXED: Updated to Type key to align perfectly with your ToolController registry!
  final Map<Type, DrawTool> tools;

  // --- Viewport Matrices & Bounding Artboard Injections ---
  final Matrix4 transform;
  final double canvasWidth;
  final double canvasHeight;

  const MyPainter({
    required this.drawHistory, 
    required this.tools, 
    required this.transform,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Open a clean graphics state configuration container anchor frame.
    canvas.save();
    
    // 2. THE CANVASKIT CORE: Apply the camera pan/zoom matrix directly into the painter buffer!
    canvas.transform(transform.storage);

    // 3. Define the rigid bounding layout box dimensions of your paper document sheet.
    final Rect artboardRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);

    // 4. HARDWARE-CLIP ANYTHING PAST THE EXPANDABLE ARTBOARD LIMITS.
    // 🟢 FIXED: Enabled doAntiAlias to guarantee a perfectly smooth paper boundary edge at any zoom.
    canvas.clipRect(artboardRect, doAntiAlias: true);

    // 5. Loop through and execute your drawing vectors sequentially (Z-index z-depth)
    if (drawHistory.isNotEmpty) {
      for (final DrawData command in drawHistory) {
        final DrawTool? tool = _findToolByName(command.toolName);
        
        // Hand the canvas context directly back to the tool that knows how to paint itself!
        tool?.draw(canvas, command);
      }
    }

    // 6. Close the transformation frame safely to protect peripheral rendering streams.
    canvas.restore();
  }

  /// Maps the database layout tool string key hashes back to our memory tool instances.
  DrawTool? _findToolByName(String name) {
    try {
      return tools.values.firstWhere((t) => t.toolName == name);
    } catch (_) {
      return null;
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    // HIGH-PERFORMANCE GPU CACHING OPTIMIZATION:
    // Skips heavy vector repaint loops entirely unless data values or matrix dimensions actively update.
    return oldDelegate.drawHistory != drawHistory || 
           oldDelegate.transform != transform ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.canvasHeight != canvasHeight;
  }
}
