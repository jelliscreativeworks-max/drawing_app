// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draw_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrawData {

 String get layerId; String get toolName; int get index; String get id;@PaintConverter() Paint? get strokeSettings;@PaintConverter() Paint? get fillSettings;@OffsetConverter() List<Offset> get points;
/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawDataCopyWith<DrawData> get copyWith => _$DrawDataCopyWithImpl<DrawData>(this as DrawData, _$identity);

  /// Serializes this DrawData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,index,id,strokeSettings,fillSettings,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'DrawData(layerId: $layerId, toolName: $toolName, index: $index, id: $id, strokeSettings: $strokeSettings, fillSettings: $fillSettings, points: $points)';
}


}

/// @nodoc
abstract mixin class $DrawDataCopyWith<$Res>  {
  factory $DrawDataCopyWith(DrawData value, $Res Function(DrawData) _then) = _$DrawDataCopyWithImpl;
@useResult
$Res call({
 String layerId, String toolName, int index, String id,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings,@OffsetConverter() List<Offset> points
});




}
/// @nodoc
class _$DrawDataCopyWithImpl<$Res>
    implements $DrawDataCopyWith<$Res> {
  _$DrawDataCopyWithImpl(this._self, this._then);

  final DrawData _self;
  final $Res Function(DrawData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layerId = null,Object? toolName = null,Object? index = null,Object? id = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,Object? points = null,}) {
  return _then(_self.copyWith(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,
  ));
}

}


/// Adds pattern-matching-related methods to [DrawData].
extension DrawDataPatterns on DrawData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrawData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrawData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrawData value)  $default,){
final _that = this;
switch (_that) {
case _DrawData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrawData value)?  $default,){
final _that = this;
switch (_that) {
case _DrawData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String layerId,  String toolName,  int index,  String id, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrawData() when $default != null:
return $default(_that.layerId,_that.toolName,_that.index,_that.id,_that.strokeSettings,_that.fillSettings,_that.points);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String layerId,  String toolName,  int index,  String id, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)  $default,) {final _that = this;
switch (_that) {
case _DrawData():
return $default(_that.layerId,_that.toolName,_that.index,_that.id,_that.strokeSettings,_that.fillSettings,_that.points);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String layerId,  String toolName,  int index,  String id, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)?  $default,) {final _that = this;
switch (_that) {
case _DrawData() when $default != null:
return $default(_that.layerId,_that.toolName,_that.index,_that.id,_that.strokeSettings,_that.fillSettings,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrawData implements DrawData {
  const _DrawData({required this.layerId, required this.toolName, required this.index, required this.id, @PaintConverter() this.strokeSettings, @PaintConverter() this.fillSettings, @OffsetConverter() required final  List<Offset> points}): _points = points;
  factory _DrawData.fromJson(Map<String, dynamic> json) => _$DrawDataFromJson(json);

@override final  String layerId;
@override final  String toolName;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint? strokeSettings;
@override@PaintConverter() final  Paint? fillSettings;
 final  List<Offset> _points;
@override@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawDataCopyWith<_DrawData> get copyWith => __$DrawDataCopyWithImpl<_DrawData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrawData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,index,id,strokeSettings,fillSettings,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'DrawData(layerId: $layerId, toolName: $toolName, index: $index, id: $id, strokeSettings: $strokeSettings, fillSettings: $fillSettings, points: $points)';
}


}

/// @nodoc
abstract mixin class _$DrawDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory _$DrawDataCopyWith(_DrawData value, $Res Function(_DrawData) _then) = __$DrawDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, String toolName, int index, String id,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings,@OffsetConverter() List<Offset> points
});




}
/// @nodoc
class __$DrawDataCopyWithImpl<$Res>
    implements _$DrawDataCopyWith<$Res> {
  __$DrawDataCopyWithImpl(this._self, this._then);

  final _DrawData _self;
  final $Res Function(_DrawData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? toolName = null,Object? index = null,Object? id = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,Object? points = null,}) {
  return _then(_DrawData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,
  ));
}


}

// dart format on
