import 'dart:typed_data';

import 'package:drawing_app/ui/core/commands/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_data/draw_data.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'layer_data.freezed.dart';  
part 'layer_data.g.dart';  


@freezed
abstract class LayerData with _$LayerData {
  factory LayerData({
    required String id,
    required int index,
    required String name,
    required String canvasId,
    @Default(1.0) double opacity,
    @Default(true) bool isDirty,
    @Default(true) bool isVisible,
    @Default(<DrawData>[]) List<DrawData> layerDrawHistory,


      
}) = _LayerData;

factory LayerData.fromJson(Map<String, dynamic> json) => _$LayerDataFromJson(json);

}