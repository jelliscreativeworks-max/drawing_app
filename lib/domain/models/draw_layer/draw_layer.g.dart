// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawLayer _$DrawLayerFromJson(Map<String, dynamic> json) => _DrawLayer(
  zIndex: (json['zIndex'] as num).toInt(),
  id: json['id'] as String,
  name: json['name'] as String,
  canvasId: json['canvasId'] as String,
  isDirty: json['isDirty'] as bool? ?? true,
  layerSnapShot: _$JsonConverterFromJson<String, Uint8List>(
    json['layerSnapShot'],
    const Uint8ListConverter().fromJson,
  ),
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
  'zIndex': instance.zIndex,
  'id': instance.id,
  'name': instance.name,
  'canvasId': instance.canvasId,
  'isDirty': instance.isDirty,
  'layerSnapShot': _$JsonConverterToJson<String, Uint8List>(
    instance.layerSnapShot,
    const Uint8ListConverter().toJson,
  ),
  'layerDrawHistory': instance.layerDrawHistory.map((e) => e.toJson()).toList(),
  'isVisible': instance.isVisible,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
