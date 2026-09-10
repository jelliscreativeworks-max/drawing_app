// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawData _$DrawDataFromJson(Map<String, dynamic> json) => _DrawData(
  layerId: json['layerId'] as String,
  toolName: json['toolName'] as String,
  index: (json['index'] as num).toInt(),
  strokeSettings: _$JsonConverterFromJson<Map<String, dynamic>, Paint>(
    json['strokeSettings'],
    const PaintConverter().fromJson,
  ),
  fillSettings: _$JsonConverterFromJson<Map<String, dynamic>, Paint>(
    json['fillSettings'],
    const PaintConverter().fromJson,
  ),
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DrawDataToJson(_DrawData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'toolName': instance.toolName,
  'index': instance.index,
  'strokeSettings': _$JsonConverterToJson<Map<String, dynamic>, Paint>(
    instance.strokeSettings,
    const PaintConverter().toJson,
  ),
  'fillSettings': _$JsonConverterToJson<Map<String, dynamic>, Paint>(
    instance.fillSettings,
    const PaintConverter().toJson,
  ),
  'points': instance.points.map(const OffsetConverter().toJson).toList(),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
