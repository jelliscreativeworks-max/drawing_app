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
  renderStroke: json['renderStroke'] as bool,
  renderFill: json['renderFill'] as bool,
  center: const OffsetConverter().fromJson(
    json['center'] as Map<String, dynamic>,
  ),
  radius: (json['radius'] as num).toDouble(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CircleDataToJson(CircleData instance) =>
    <String, dynamic>{
      'layerId': instance.layerId,
      'index': instance.index,
      'id': instance.id,
      'strokePaint': const PaintConverter().toJson(instance.strokePaint),
      'fillPaint': const PaintConverter().toJson(instance.fillPaint),
      'renderStroke': instance.renderStroke,
      'renderFill': instance.renderFill,
      'center': const OffsetConverter().toJson(instance.center),
      'radius': instance.radius,
      'runtimeType': instance.$type,
    };

FreehandData _$FreehandDataFromJson(Map<String, dynamic> json) => FreehandData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  renderStroke: json['renderStroke'] as bool,
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$FreehandDataToJson(FreehandData instance) =>
    <String, dynamic>{
      'layerId': instance.layerId,
      'index': instance.index,
      'id': instance.id,
      'strokePaint': const PaintConverter().toJson(instance.strokePaint),
      'renderStroke': instance.renderStroke,
      'points': instance.points.map(const OffsetConverter().toJson).toList(),
      'runtimeType': instance.$type,
    };

LineData _$LineDataFromJson(Map<String, dynamic> json) => LineData(
  layerId: json['layerId'] as String,
  index: (json['index'] as num).toInt(),
  id: json['id'] as String,
  renderStroke: json['renderStroke'] as bool,
  strokePaint: const PaintConverter().fromJson(
    json['strokePaint'] as Map<String, dynamic>,
  ),
  startPoint: const OffsetConverter().fromJson(
    json['startPoint'] as Map<String, dynamic>,
  ),
  endPoint: const OffsetConverter().fromJson(
    json['endPoint'] as Map<String, dynamic>,
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$LineDataToJson(LineData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'renderStroke': instance.renderStroke,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'startPoint': const OffsetConverter().toJson(instance.startPoint),
  'endPoint': const OffsetConverter().toJson(instance.endPoint),
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
  renderStroke: json['renderStroke'] as bool,
  renderFill: json['renderFill'] as bool,
  closed: json['closed'] as bool? ?? false,
  points: (json['points'] as List<dynamic>)
      .map((e) => const OffsetConverter().fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$PathDataToJson(PathData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'fillPaint': const PaintConverter().toJson(instance.fillPaint),
  'renderStroke': instance.renderStroke,
  'renderFill': instance.renderFill,
  'closed': instance.closed,
  'points': instance.points.map(const OffsetConverter().toJson).toList(),
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
  renderStroke: json['renderStroke'] as bool,
  renderFill: json['renderFill'] as bool,
  topLeft: const OffsetConverter().fromJson(
    json['topLeft'] as Map<String, dynamic>,
  ),
  botRight: const OffsetConverter().fromJson(
    json['botRight'] as Map<String, dynamic>,
  ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$RectDataToJson(RectData instance) => <String, dynamic>{
  'layerId': instance.layerId,
  'index': instance.index,
  'id': instance.id,
  'strokePaint': const PaintConverter().toJson(instance.strokePaint),
  'fillPaint': const PaintConverter().toJson(instance.fillPaint),
  'renderStroke': instance.renderStroke,
  'renderFill': instance.renderFill,
  'topLeft': const OffsetConverter().toJson(instance.topLeft),
  'botRight': const OffsetConverter().toJson(instance.botRight),
  'runtimeType': instance.$type,
};
