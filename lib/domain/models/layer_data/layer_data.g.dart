// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layer_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LayerData _$LayerDataFromJson(Map<String, dynamic> json) => _LayerData(
  id: json['id'] as String,
  index: (json['index'] as num).toInt(),
  name: json['name'] as String,
  canvasId: json['canvasId'] as String,
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
  isDirty: json['isDirty'] as bool? ?? true,
  isVisible: json['isVisible'] as bool? ?? true,
  layerDrawHistory:
      (json['layerDrawHistory'] as List<dynamic>?)
          ?.map((e) => DrawData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <DrawData>[],
);

Map<String, dynamic> _$LayerDataToJson(
  _LayerData instance,
) => <String, dynamic>{
  'id': instance.id,
  'index': instance.index,
  'name': instance.name,
  'canvasId': instance.canvasId,
  'opacity': instance.opacity,
  'isDirty': instance.isDirty,
  'isVisible': instance.isVisible,
  'layerDrawHistory': instance.layerDrawHistory.map((e) => e.toJson()).toList(),
};
