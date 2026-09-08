import 'dart:typed_data';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'canvas_data.freezed.dart';  
part 'canvas_data.g.dart';  


@freezed
abstract class CanvasData with _$CanvasData {

  factory CanvasData({
    required String id,
    required String name,
    required List<String> layerIds

      
}) = _CanvasData;

factory CanvasData.fromJson(Map<String, dynamic> json) => _$CanvasDataFromJson(json);

}