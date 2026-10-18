// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draw_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CircleData _$CircleDataFromJson(Map<String, dynamic> json) => CircleData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  fillPaint: const PaintConverter().fromJson(
    json['fillPaint'] as Map<String, dynamic>,
  ),
  center: const OffsetConverter().fromJson(
    json['center'] as Map<String, dynamic>,
  ),
  radius: (json['radius'] as num).toDouble(),
  strokeType: $enumDecode(_$StrokeTypeOptionsEnumMap, json['strokeType']),
  fillType: $enumDecode(_$FillTypeOptionsEnumMap, json['fillType']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CircleDataToJson(CircleData instance) =>
    <String, dynamic>{
      'layerId': instance.layerId,
      'index': instance.index,
      'id': instance.id,
      'strokePaint': const PaintConverter().toJson(instance.strokePaint),
      'fillPaint': const PaintConverter().toJson(instance.fillPaint),
      'center': const OffsetConverter().toJson(instance.center),
      'radius': instance.radius,
      'strokeType': _$StrokeTypeOptionsEnumMap[instance.strokeType]!,
      'fillType': _$FillTypeOptionsEnumMap[instance.fillType]!,
      'runtimeType': instance.$type,
    };

const _$StrokeTypeOptionsEnumMap = {
  StrokeTypeOptions.noStroke: 0,
  StrokeTypeOptions.solid: 1,
};

const _$FillTypeOptionsEnumMap = {
  FillTypeOptions.noFill: 0,
  FillTypeOptions.filled: 1,
};

FreehandData _$FreehandDataFromJson(Map<String, dynamic> json) => FreehandData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  strokeType: $enumDecode(_$StrokeTypeOptionsEnumMap, json['strokeType']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$FreehandDataToJson(FreehandData instance) =>
    <String, dynamic>{
      'layerId': instance.layerId,
      'index': instance.index,
      'id': instance.id,
      'strokePaint': const PaintConverter().toJson(instance.strokePaint),
      'points': instance.points.map(const OffsetConverter().toJson).toList(),
      'strokeType': _$StrokeTypeOptionsEnumMap[instance.strokeType]!,
      'runtimeType': instance.$type,
    };

LineData _$LineDataFromJson(Map<String, dynamic> json) => LineData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  startPoint: const OffsetConverter().fromJson(
    json['startPoint'] as Map<String, dynamic>,
  ),
  endPoint: const OffsetConverter().fromJson(
    json['endPoint'] as Map<String, dynamic>,
  ),
  strokeType: $enumDecode(_$StrokeTypeOptionsEnumMap, json['strokeType']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LineDataToJson(LineData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'startPoint': const OffsetConverter().toJson(instance.startPoint),
  'endPoint': const OffsetConverter().toJson(instance.endPoint),
  'strokeType': _$StrokeTypeOptionsEnumMap[instance.strokeType]!,
  'runtimeType': instance.$type,
};

PathData _$PathDataFromJson(Map<String, dynamic> json) => PathData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  fillPaint: const PaintConverter().fromJson(
    json['fillPaint'] as Map<String, dynamic>,
  ),
  closed: json['closed'] as bool? ?? false,
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  strokeType: $enumDecode(_$StrokeTypeOptionsEnumMap, json['strokeType']),
  fillType: $enumDecode(_$FillTypeOptionsEnumMap, json['fillType']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$PathDataToJson(PathData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'fillPaint': const PaintConverter().toJson(instance.fillPaint),
  'closed': instance.closed,
  'points': instance.points.map(const OffsetConverter().toJson).toList(),
  'strokeType': _$StrokeTypeOptionsEnumMap[instance.strokeType]!,
  'fillType': _$FillTypeOptionsEnumMap[instance.fillType]!,
  'runtimeType': instance.$type,
};

RectData _$RectDataFromJson(Map<String, dynamic> json) => RectData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  fillPaint: const PaintConverter().fromJson(
    json['fillPaint'] as Map<String, dynamic>,
  ),
  topLeft: const OffsetConverter().fromJson(
    json['topLeft'] as Map<String, dynamic>,
  ),
  botRight: const OffsetConverter().fromJson(
    json['botRight'] as Map<String, dynamic>,
  ),
  strokeType: $enumDecode(_$StrokeTypeOptionsEnumMap, json['strokeType']),
  fillType: $enumDecode(_$FillTypeOptionsEnumMap, json['fillType']),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$RectDataToJson(RectData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'fillPaint': const PaintConverter().toJson(instance.fillPaint),
  'topLeft': const OffsetConverter().toJson(instance.topLeft),
  'botRight': const OffsetConverter().toJson(instance.botRight),
  'strokeType': _$StrokeTypeOptionsEnumMap[instance.strokeType]!,
  'fillType': _$FillTypeOptionsEnumMap[instance.fillType]!,
  'runtimeType': instance.$type,
};
