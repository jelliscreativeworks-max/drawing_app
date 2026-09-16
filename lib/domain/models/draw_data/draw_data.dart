import 'dart:math';
import 'dart:ui';

import 'package:drawing_app/utils/converters.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_data.freezed.dart';  
part 'draw_data.g.dart';  
part 'draw_data_rendering.dart';
part 'draw_data_collisions.dart';
part 'draw_data_extensions.dart';

@freezed
sealed class DrawData with _$DrawData{
  // const DrawData._();
  // const factory DrawData({
  //    required String layerId,
  //    required String toolName,
  //    required int index,
  //    required String id,
  //    @PaintConverter() Paint? strokeSettings,
  //    @PaintConverter() Paint? fillSettings,
  //    @OffsetConverter() required List<Offset> points
  // }) = _DrawData;

  const factory DrawData.circle({
    required String layerId,
    required int index,
    required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    required bool renderStroke,
    required bool renderFill,
    @OffsetConverter() required Offset center,
    required double radius,

    
  }) = CircleData;

  const factory DrawData.freehand({
    required String layerId,
    required int index,
    required String id,
    @PaintConverter() required Paint strokePaint,
    required bool renderStroke,
    @OffsetConverter() required List<Offset> points
  }) = FreehandData;

  const factory DrawData.line({
    required String layerId,
    required int index,
    required String id,
    required bool renderStroke,
    @PaintConverter() required Paint strokePaint,
    @OffsetConverter() required Offset startPoint,
    @OffsetConverter() required Offset endPoint
  }) = LineData;

  const factory DrawData.path({
    required String layerId,
    required int index,
     required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    required bool renderStroke,
    required bool renderFill,
    @Default(false) bool closed,
    @OffsetConverter() required List<Offset> points
  }) = PathData;

  const factory DrawData.rectangle({
    required String layerId,
    required int index,
     required String id,
    @PaintConverter() required Paint strokePaint,
    @PaintConverter() required Paint fillPaint,
    required bool renderStroke,
    required bool renderFill,
    @OffsetConverter() required Offset topLeft,
    @OffsetConverter() required Offset botRight,

  }) = RectData;



  factory DrawData.fromJson(Map<String, dynamic> json) => _$DrawDataFromJson(json);

  

}




