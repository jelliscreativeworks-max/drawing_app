import 'dart:ui';

import 'package:drawing_app/domain/models/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_command.freezed.dart';  
part 'draw_command.g.dart';

@freezed
abstract class DrawCommand with _$DrawCommand {
  const DrawCommand._();
  factory DrawCommand.data({
      required String toolName,
      required String layerId,
      @OffsetConverter() required List<Offset> points,
      @PaintConverter() Paint? strokeSettings,
      @PaintConverter() Paint? fillSettings,
      
}) = _DrawCommandData;

void draw(Canvas canvas,DrawTool tool){
  tool.draw(canvas,this);
}

factory DrawCommand.fromJson(Map<String, dynamic> json) => _$DrawCommandFromJson(json);

}