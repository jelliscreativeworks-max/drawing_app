import 'dart:ui';

import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';

class EraseTool extends DrawTool{
  EraseTool({required super.toolName, required super.toolIcon});

  @override
  bool get isEraserTool => true;
  
  @override
  void draw(Canvas canvas, DrawCommand drawCommand) {
    
  }

  @override
  DrawCommand onDrawEnd(DrawCommand currentCommand) {
    // TODO: implement onDrawEnd
    throw UnimplementedError();
  }

  @override
  DrawCommand onDrawStart(Offset startPoint, Paint strokeSettings, Paint fillSettings, String layerId) {
    // TODO: implement onDrawStart
    throw UnimplementedError();
  }

  @override
  DrawCommand onUpdateTool(DrawCommand currentCommand, Offset newPoint) {
    // TODO: implement onUpdateTool
    throw UnimplementedError();
  }
}