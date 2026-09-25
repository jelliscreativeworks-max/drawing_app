import 'dart:ui';
import 'package:drawing_app/domain/models/canvas_camera.dart';
import 'package:flutter/material.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/ui/core/draw_tools/canvas_tool.dart'; // Ensure correct path mapping

class MyPainter extends CustomPainter {
  final List<DrawData> drawHistory;
  final ToolMatrixPayload camera;
  final double canvasWidth;
  final double canvasHeight;
  final PointerDeviceKind deviceKind;
  final Set<String> deletionTargets; 

  final CanvasTool? activeTool;

  const MyPainter({
    required this.deviceKind,
    required this.drawHistory, 
    required this.camera,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.deletionTargets,
    this.activeTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.transform(camera.transform.storage);

    final Rect artboardRect = Rect.fromLTWH(0, 0, canvasWidth, canvasHeight);
    canvas.clipRect(artboardRect, doAntiAlias: true);
    if (drawHistory.isNotEmpty) {
      for (final DrawData data in drawHistory) {
        if (deletionTargets.contains(data.id)) {
          final Paint layerPaint = Paint()
            ..colorFilter = const ColorFilter.mode(
              Color(0xFFD3D3D3), // Solid Light Grey
              BlendMode.srcIn,
            );


          canvas.saveLayer(artboardRect, layerPaint);
          
          data.draw(canvas); 
          
          canvas.restore(); 
        } else {
          data.draw(canvas);
        }
      }
    }







    // Allow tools to draw non-data UI decorators (like path node rings) over the lines
    // Pass the current matrix scale factor so sizes stay completely uniform when zooming
    if (activeTool != null) {
      final double currentScale = camera.currentScale;
      activeTool!.drawToolOverlay(canvas, deviceKind, currentScale);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    bool should = oldDelegate.drawHistory != drawHistory || 
           oldDelegate.camera.transform != camera.transform ||
           oldDelegate.canvasWidth != canvasWidth ||
           oldDelegate.canvasHeight != canvasHeight ||
           oldDelegate.activeTool != activeTool ||
           oldDelegate.deletionTargets != deletionTargets;
           oldDelegate.camera.currentScale != camera.currentScale;

    return should;
  }
}
