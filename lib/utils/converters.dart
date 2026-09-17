
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class OffsetConverter implements JsonConverter<Offset, Map<String, dynamic>>{
  const OffsetConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble()
    );
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {
      'x' : object.dx,
      'y' : object.dy 
    };
  }
}


class Uint8ListConverter implements JsonConverter<Uint8List,String>{
  const Uint8ListConverter();
  @override
  Uint8List fromJson(String json) {
    String base64String = json;

    return base64Decode(base64String);
  }

  @override
  String toJson(Uint8List object) {
    String base64String = base64Encode(object);

    return base64String;
  }
  
}


class PaintConverter implements JsonConverter<Paint, Map<String, dynamic>> {
  const PaintConverter();

  @override
  Paint fromJson(Map<String, dynamic> json) {
    final paint = Paint()
      ..strokeWidth = (json['strokeWidth'] as num).toDouble();

    // 1. Safe Color parsing checking for both signed and unsigned 32-bit integers
    final int colorValue = json['color'] as int;
    paint.color = Color(colorValue.toUnsigned(32));

    // 2. Crash-proof Enum parsing using safe range guard fallbacks
    final int blendIndex = json['blendMode'] as int;
    paint.blendMode = blendIndex >= 0 && blendIndex < BlendMode.values.length
        ? BlendMode.values[blendIndex]
        : BlendMode.srcOver; // Default fallback if enum definition changes

    final int styleIndex = json['style'] as int;
    paint.style = styleIndex >= 0 && styleIndex < PaintingStyle.values.length
        ? PaintingStyle.values[styleIndex]
        : PaintingStyle.stroke;

    final int capIndex = json['strokeCap'] as int;
    paint.strokeCap = capIndex >= 0 && capIndex < StrokeCap.values.length
        ? StrokeCap.values[capIndex]
        : StrokeCap.round;

    return paint;
  }

  @override
  Map<String, dynamic> toJson(Paint object) {
    return {
      // toARGB32() is perfect, but ensure it forces an unsigned 32-bit structure
      'color': object.color.toARGB32(),
      'strokeWidth': object.strokeWidth,
      'blendMode': object.blendMode.index,
      'style': object.style.index,
      'strokeCap': object.strokeCap.index,
    };
  }
}



class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.toARGB32();
}
