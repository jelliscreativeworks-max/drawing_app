// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CanvasData _$CanvasDataFromJson(Map<String, dynamic> json) => _CanvasData(
  id: json['id'] as String,
  name: json['name'] as String,
  layerIds: (json['layerIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CanvasDataToJson(_CanvasData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layerIds': instance.layerIds,
    };
