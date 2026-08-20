// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_line_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrawLine _$DrawLineFromJson(Map<String, dynamic> json) => _DrawLine(
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  strokeColor: const ColorConverter().fromJson(
    (json['strokeColor'] as num).toInt(),
  ),
  strokeCap: $enumDecode(_$StrokeCapEnumMap, json['strokeCap']),
  strokeWidth: (json['strokeWidth'] as num).toDouble(),
);

Map<String, dynamic> _$DrawLineToJson(_DrawLine instance) => <String, dynamic>{
  'points': instance.points.map(const OffsetConverter().toJson).toList(),
  'strokeColor': const ColorConverter().toJson(instance.strokeColor),
  'strokeCap': _$StrokeCapEnumMap[instance.strokeCap]!,
  'strokeWidth': instance.strokeWidth,
};

const _$StrokeCapEnumMap = {
  StrokeCap.butt: 'butt',
  StrokeCap.round: 'round',
  StrokeCap.square: 'square',
};
