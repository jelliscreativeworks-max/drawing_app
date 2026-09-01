import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/freehand_tool.dart';
import 'package:drawing_app/domain/models/draw_tools/pan_tool.dart';
import 'package:flutter/material.dart';

class DrawToolsList {
  DrawToolsList._();

  static DrawTool freehand = FreehandTool(toolName: 'Freehand Tool', toolIcon: Icon(Icons.draw), );
  static DrawTool pan = PanTool(toolName: 'Pan Tool', toolIcon: Icon(Icons.pan_tool));

   static final Map<String, DrawTool> map = {
    'Freehand Tool': freehand,
    'Pan Tool': pan,
  };
}