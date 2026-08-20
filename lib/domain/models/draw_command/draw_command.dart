import 'dart:ui';

import 'package:drawing_app/utils/converters.dart';
import 'package:drawing_app/domain/draw_tools/draw_tool.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_command.freezed.dart';  
part 'draw_command.g.dart';

@freezed
sealed class DrawCommand with _$DrawCommand {
  DrawCommand._({Paint? strokeSettings, Paint? fillSettings}) : strokeSettings = strokeSettings ?? Paint(), fillSettings = fillSettings ?? Paint() ;
  factory DrawCommand.data({
      required String toolName,
      @OffsetConverter() required List<Offset> points,
      @PaintConverter() Paint? strokeSettings,
      @PaintConverter() Paint? fillSettings,
      
}) = _DrawCommandData;

void draw(Canvas canvas,DrawTool tool){
  tool.draw(canvas,this);
}

@override
@PaintConverter() final Paint strokeSettings;

@override
@PaintConverter() final Paint fillSettings;

factory DrawCommand.fromJson(Map<String, dynamic> json) => _$DrawCommandFromJson(json);

}