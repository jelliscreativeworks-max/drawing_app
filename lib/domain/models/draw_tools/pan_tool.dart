import 'dart:ui';

import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:flutter/material.dart';

class PanTool extends DrawTool{
  PanTool({required super.toolName, required super.toolIcon}); 

  @override
  bool get isNavigationTool => true;

  @override
  void draw(Canvas canvas, DrawCommand drawCommand){}

  @override
  DrawCommand onDrawEnd(DrawCommand currentCommand) => currentCommand;

  @override
  DrawCommand onDrawStart(Offset startPoint, Paint strokeSettings, Paint fillSettings, String layerId) {
    return DrawCommand.data(toolName: toolName, layerId: layerId, points: const[]);
  }

  @override
  DrawCommand onUpdateTool(DrawCommand currentCommand, Offset newPoint) => currentCommand;
  
}