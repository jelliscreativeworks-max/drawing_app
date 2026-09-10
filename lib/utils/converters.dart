
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

  // TODO: Modify Paint json conversion to store additional properties
class PaintConverter implements JsonConverter<Paint, Map<String, dynamic>> {
  const PaintConverter();

  @override
  Paint fromJson(Map<String, dynamic> json) {
    return Paint()
      ..color = Color(json['color'] as int)
      ..strokeWidth = (json['strokeWidth'] as num).toDouble()
      ..blendMode = BlendMode.values[json['blendMode'] as int]
      ..style = PaintingStyle.values[json['style'] as int]
      ..strokeCap = StrokeCap.values[json['strokeCap'] as int]; 
      
  }

  @override
  Map<String, dynamic> toJson(Paint object) {
    return {
      'color': object.color.toARGB32(),
      'strokeWidth': object.strokeWidth,
      'blendMode': object.blendMode.index,
      'style': object.style.index,
      'strokeCap': object.strokeCap.index
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
