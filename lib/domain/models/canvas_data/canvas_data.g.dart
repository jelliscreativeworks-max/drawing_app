// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CanvasDataCreated _$CanvasDataCreatedFromJson(Map<String, dynamic> json) =>
    CanvasDataCreated(
      id: json['id'] as String,
      name: json['name'] as String,
      layerIds: (json['layerIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      canvasSize: const SizeConverter().fromJson(
        json['canvasSize'] as Map<String, dynamic>,
      ),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$CanvasDataCreatedToJson(CanvasDataCreated instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layerIds': instance.layerIds,
      'canvasSize': const SizeConverter().toJson(instance.canvasSize),
      'runtimeType': instance.$type,
    };

CanvasDataPlaceHolder _$CanvasDataPlaceHolderFromJson(
  Map<String, dynamic> json,
) => CanvasDataPlaceHolder(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? 'untitled',
  layerIds:
      (json['layerIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  canvasSize: json['canvasSize'] == null
      ? const Size(2000, 2000)
      : const SizeConverter().fromJson(
          json['canvasSize'] as Map<String, dynamic>,
        ),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$CanvasDataPlaceHolderToJson(
  CanvasDataPlaceHolder instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'layerIds': instance.layerIds,
  'canvasSize': const SizeConverter().toJson(instance.canvasSize),
  'runtimeType': instance.$type,
};
