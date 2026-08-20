import 'package:drawing_app/domain/draw_tools/draw_tool.dart';
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



class PaintConverter implements JsonConverter<Paint, Map<String, dynamic>>{
  const PaintConverter();
  @override
  Paint fromJson(Map<String, dynamic> json) {
    return Paint()
    ..blendMode = json['blendMode']
    ..color = json['color']
    ..style = json['style']
    ..strokeWidth = json['strokeWidth']
    ..strokeCap = json['strokeCap']
    ..strokeJoin = json['strokeJoin'];
  }

  @override
  Map<String, dynamic> toJson(Paint object) {
    return{
      'blendMode' : object.blendMode,
      'color' : object.color.toARGB32(),
      // 'colorFilter'
      'style' : object.style,
      'strokeWidth' : object.strokeWidth,
      'strokeCap' : object.strokeCap,
      'strokeJoin' : object.strokeJoin,
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
