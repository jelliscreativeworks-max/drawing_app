import 'dart:ui';

import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';

class EraseTool extends DrawTool{
  EraseTool({required super.toolName, required super.toolIcon});


  @override
  void draw(Canvas canvas, DrawCommand drawCommand) {
    
  }

  @override
  void onDrawEnd({required DrawCommand? activeCommand, required String layerId, required List<DrawCommand> drawHistory, required Map<String, List<DrawCommand>> layerDrawHistory, required ToolMatrixPayload camera}) {
    // TODO: implement onDrawEnd
  }

  @override
  DrawCommand? onDrawStart({required Offset startPoint, required Paint strokeSettings, required Paint fillSettings, required String layerId, required List<DrawCommand> drawHistory, required Map<String, List<DrawCommand>> layerDrawHistory, required ToolMatrixPayload camera}) {
    // TODO: implement onDrawStart
    throw UnimplementedError();
  }

  @override
  DrawCommand? onUpdateTool({required DrawCommand activeCommand, required Offset newPoint, required List<DrawCommand> drawHistory, required Map<String, List<DrawCommand>> layerDrawHistory, required ToolMatrixPayload camera, required int pointerCount, required double gestureScale}) {
    // TODO: implement onUpdateTool
    throw UnimplementedError();
  }


}