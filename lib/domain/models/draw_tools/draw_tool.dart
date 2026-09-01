import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:flutter/material.dart';

abstract class DrawTool{
  final String toolName;
  final Icon toolIcon;

  const DrawTool({required this.toolName, required this.toolIcon});

  bool get isNavigationTool => false;

  // Pure functions: Accept a command, return a brand new updated Freezed command instance
  DrawCommand onDrawStart(Offset startPoint, Paint strokeSettings, Paint fillSettings, String layerId);
  DrawCommand onUpdateTool(DrawCommand currentCommand, Offset newPoint);
  DrawCommand onDrawEnd(DrawCommand currentCommand);

  // The rendering logic
  void draw(Canvas canvas, DrawCommand drawCommand);
}
