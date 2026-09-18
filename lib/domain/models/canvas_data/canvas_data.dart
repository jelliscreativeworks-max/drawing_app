import 'dart:ui';
import 'package:drawing_app/utils/converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'canvas_data.freezed.dart';  
part 'canvas_data.g.dart';  

@Freezed(unionKey: 'runtimeType', fallbackUnion: 'default')
sealed class CanvasData with _$CanvasData {
  const CanvasData._();

  const factory CanvasData({
    required String id,
    required String name,
    required List<String> layerIds,
    @SizeConverter() required Size canvasSize,
  }) = CanvasDataCreated;

  const factory CanvasData.placeholder({
    @Default('') String id,
    @Default('untitled') String name,
    @Default([]) List<String> layerIds,
    @Default(Size(2000, 2000)) @SizeConverter() Size canvasSize,
  }) = CanvasDataPlaceHolder;

  factory CanvasData.fromJson(Map<String, dynamic> json) => _$CanvasDataFromJson(json);

  double get currentWidth => canvasSize.width;
  double get currentHeight => canvasSize.height;
}
