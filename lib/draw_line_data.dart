import 'package:drawing_app/converters.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'draw_line_data.freezed.dart';  
part 'draw_line_data.g.dart';  


@freezed
abstract class DrawLine with _$DrawLine {

  const factory DrawLine({

      @OffsetConverter() required List<Offset> points,
      @ColorConverter() required Color strokeColor,
      required StrokeCap strokeCap,
      required double strokeWidth,
}) = _DrawLine;

factory DrawLine.fromJson(Map<String, dynamic> json) => _$DrawLineFromJson(json);

}