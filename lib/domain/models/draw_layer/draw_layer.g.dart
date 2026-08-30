// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawLayer _$DrawLayerFromJson(Map<String, dynamic> json) => _DrawLayer(
  id: json['id'] as String,
  name: json['name'] as String,
  canvasId: json['canvasId'] as String,
  isDirty: json['isDirty'] as bool? ?? true,
  layerDrawHistory:
      (json['layerDrawHistory'] as List<dynamic>?)
          ?.map((e) => DrawCommand.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DrawCommand>[],
  isVisible: json['isVisible'] as bool? ?? true,
);

Map<String, dynamic> _$DrawLayerToJson(
  _DrawLayer instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'canvasId': instance.canvasId,
  'isDirty': instance.isDirty,
  'layerDrawHistory': instance.layerDrawHistory.map((e) => e.toJson()).toList(),
  'isVisible': instance.isVisible,
};
