import 'dart:ui';
import 'package:drawing_app/draw_command.dart';
import 'package:drawing_app/draw_tool.dart';
import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  final List<DrawCommand> drawHistory;
  final Map<String, DrawTool> drawTools;
  
  // 1. Pass the live active command frame directly into the painter
  final DrawCommand? activeCommand; 

  MyPainter({
    required this.drawHistory, 
    required this.drawTools, 
    required this.activeCommand,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 2. Draw all completed historical items sequentially
    for (DrawCommand command in drawHistory) {
      final tool = drawTools[command.toolName];
      if (tool != null) {
        command.draw(canvas, tool);
      }
    }

    // 3. Draw the active live user path in real-time if it exists
    if (activeCommand != null) {
      final tool = drawTools[activeCommand!.toolName];
      if (tool != null) {
        activeCommand!.draw(canvas, tool);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    // 4. Optimize repaints: Skip redraw loops unless reference pointers change
    return oldDelegate.drawHistory != drawHistory || 
           oldDelegate.activeCommand != activeCommand ||
           oldDelegate.drawTools != drawTools;
  }
}
