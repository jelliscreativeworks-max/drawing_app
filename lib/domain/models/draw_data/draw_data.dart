import 'dart:ui';

import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_data.freezed.dart';  
part 'draw_data.g.dart';  

@freezed
abstract class DrawData with _$DrawData{
  const factory DrawData({
     required String layerId,
     required String toolName,
     required int index,
     @PaintConverter() Paint? strokeSettings,
     @PaintConverter() Paint? fillSettings,
     @OffsetConverter() required List<Offset> points
  }) = _DrawData;

  factory DrawData.fromJson(Map<String, dynamic> json) => _$DrawDataFromJson(json);



}