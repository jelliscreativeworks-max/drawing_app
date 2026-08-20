import 'package:drawing_app/draw_command.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draw_layer.freezed.dart';  
part 'draw_layer.g.dart';  


@freezed
abstract class DrawLayer with _$DrawLayer {

  const factory DrawLayer({
    required String id,
    required String name,
    @Default([]) List<DrawCommand> layerDrawHistory,
    @Default(true) bool isVisible
      
}) = _DrawLayer;

factory DrawLayer.fromJson(Map<String, dynamic> json) => _$DrawLayerFromJson(json);

}