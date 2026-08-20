// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawCommandData _$DrawCommandDataFromJson(Map<String, dynamic> json) =>
    _DrawCommandData(
      toolName: json['toolName'] as String,
      layerId: json['layerId'] as String,
      points: (json['points'] as List<dynamic>)
          .map(
            (e) => const OffsetConverter().fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      strokeSettings: _$JsonConverterFromJson<Map<String, dynamic>, Paint>(
        json['strokeSettings'],
        const PaintConverter().fromJson,
      ),
      fillSettings: _$JsonConverterFromJson<Map<String, dynamic>, Paint>(
        json['fillSettings'],
        const PaintConverter().fromJson,
      ),
    );

Map<String, dynamic> _$DrawCommandDataToJson(_DrawCommandData instance) =>
    <String, dynamic>{
      'strokeSettings': const PaintConverter().toJson(instance.strokeSettings),
      'fillSettings': const PaintConverter().toJson(instance.fillSettings),
      'toolName': instance.toolName,
      'layerId': instance.layerId,
      'points': instance.points.map(const OffsetConverter().toJson).toList(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);
