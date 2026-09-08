import 'dart:typed_data';

import 'package:drawing_app/domain/models/canvas_command/canvas_command.dart';
import 'package:drawing_app/domain/models/draw_command/draw_command.dart';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_layer.freezed.dart';  
part 'draw_layer.g.dart';  


@freezed
abstract class DrawLayer with _$DrawLayer {
  factory DrawLayer({
    required String id,
    required String name,
    required String canvasId,
    @Default(true) bool isDirty,
    @Default(<DrawCommand>[]) List<DrawCommand> layerDrawHistory,
    @Default(true) bool isVisible,

      
}) = _DrawLayer;

factory DrawLayer.fromJson(Map<String, dynamic> json) => _$DrawLayerFromJson(json);

}