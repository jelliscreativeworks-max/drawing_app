// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawLayer _$DrawLayerFromJson(Map<String, dynamic> json) => _DrawLayer(
  id: json['id'] as String,
  name: json['name'] as String,
  layerDrawHistory:
      (json['layerDrawHistory'] as List<dynamic>?)
          ?.map((e) => DrawCommand.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isVisible: json['isVisible'] as bool? ?? true,
);

Map<String, dynamic> _$DrawLayerToJson(_DrawLayer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layerDrawHistory': instance.layerDrawHistory,
      'isVisible': instance.isVisible,
    };
