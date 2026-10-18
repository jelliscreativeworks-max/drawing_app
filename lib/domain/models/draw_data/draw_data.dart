import 'dart:math';
import 'dart:ui';


import 'package:drawing_app/ui/core/draw_tools/draw_tool.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:drawing_app/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_data.freezed.dart';  
part 'draw_data.g.dart';  
part 'draw_data_rendering.dart';
part 'draw_data_collisions.dart';
part 'draw_data_extensions.dart';
part 'draw_data_properties.dart';


@freezed
sealed class DrawData with _$DrawData{
  const factory DrawData.circle({
    required String layerId,
    required int index,
    required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    @OffsetConverter() required Offset center,
    required double radius,
    required StrokeTypeOptions strokeType,
    required FillTypeOptions fillType

    
  }) = CircleData;

  const factory DrawData.freehand({
    required String layerId,
    required int index,
    required String id,
    @PaintConverter() required Paint strokePaint,
    @OffsetConverter() required List<Offset> points,
    required StrokeTypeOptions strokeType,
  }) = FreehandData;

  const factory DrawData.line({
    required String layerId,
    required int index,
    required String id,
    @PaintConverter() required Paint strokePaint,
    @OffsetConverter() required Offset startPoint,
    @OffsetConverter() required Offset endPoint,
    required StrokeTypeOptions strokeType,
  }) = LineData;

  const factory DrawData.path({
    required String layerId,
    required int index,
     required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    @Default(false) bool closed,
    @OffsetConverter() required List<Offset> points,
    required StrokeTypeOptions strokeType,
    required FillTypeOptions fillType,
  }) = PathData;

  const factory DrawData.rectangle({
    required String layerId,
    required int index,
     required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    @OffsetConverter() required Offset topLeft,
    @OffsetConverter() required Offset botRight,
    required StrokeTypeOptions strokeType,
    required FillTypeOptions fillType,
  }) = RectData;



  factory DrawData.fromJson(Map<String, dynamic> json) => _$DrawDataFromJson(json);

  

}




