// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draw_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
DrawCommand _$DrawCommandFromJson(
  Map<String, dynamic> json
) {
    return _DrawCommandData.fromJson(
      json
    );
}

/// @nodoc
mixin _$DrawCommand {

 String get toolName; String get layerId;@OffsetConverter() List<Offset> get points;@PaintConverter() Paint? get strokeSettings;@PaintConverter() Paint? get fillSettings;
/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawCommandCopyWith<DrawCommand> get copyWith => _$DrawCommandCopyWithImpl<DrawCommand>(this as DrawCommand, _$identity);

  /// Serializes this DrawCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawCommand&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toolName,layerId,const DeepCollectionEquality().hash(points),strokeSettings,fillSettings);

@override
String toString() {
  return 'DrawCommand(toolName: $toolName, layerId: $layerId, points: $points, strokeSettings: $strokeSettings, fillSettings: $fillSettings)';
}


}

/// @nodoc
abstract mixin class $DrawCommandCopyWith<$Res>  {
  factory $DrawCommandCopyWith(DrawCommand value, $Res Function(DrawCommand) _then) = _$DrawCommandCopyWithImpl;
@useResult
$Res call({
 String toolName, String layerId,@OffsetConverter() List<Offset> points,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings
});




}
/// @nodoc
class _$DrawCommandCopyWithImpl<$Res>
    implements $DrawCommandCopyWith<$Res> {
  _$DrawCommandCopyWithImpl(this._self, this._then);

  final DrawCommand _self;
  final $Res Function(DrawCommand) _then;

/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? toolName = null,Object? layerId = null,Object? points = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,}) {
  return _then(_self.copyWith(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,
  ));
}

}


/// Adds pattern-matching-related methods to [DrawCommand].
extension DrawCommandPatterns on DrawCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _DrawCommandData value)?  data,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrawCommandData() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _DrawCommandData value)  data,}){
final _that = this;
switch (_that) {
case _DrawCommandData():
return data(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _DrawCommandData value)?  data,}){
final _that = this;
switch (_that) {
case _DrawCommandData() when data != null:
return data(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String toolName,  String layerId, @OffsetConverter()  List<Offset> points, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings)?  data,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrawCommandData() when data != null:
return data(_that.toolName,_that.layerId,_that.points,_that.strokeSettings,_that.fillSettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String toolName,  String layerId, @OffsetConverter()  List<Offset> points, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings)  data,}) {final _that = this;
switch (_that) {
case _DrawCommandData():
return data(_that.toolName,_that.layerId,_that.points,_that.strokeSettings,_that.fillSettings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String toolName,  String layerId, @OffsetConverter()  List<Offset> points, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings)?  data,}) {final _that = this;
switch (_that) {
case _DrawCommandData() when data != null:
return data(_that.toolName,_that.layerId,_that.points,_that.strokeSettings,_that.fillSettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrawCommandData extends DrawCommand {
   _DrawCommandData({required this.toolName, required this.layerId, @OffsetConverter() required final  List<Offset> points, @PaintConverter() this.strokeSettings, @PaintConverter() this.fillSettings}): _points = points,super._();
  factory _DrawCommandData.fromJson(Map<String, dynamic> json) => _$DrawCommandDataFromJson(json);

@override final  String toolName;
@override final  String layerId;
 final  List<Offset> _points;
@override@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override@PaintConverter() final  Paint? strokeSettings;
@override@PaintConverter() final  Paint? fillSettings;

/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawCommandDataCopyWith<_DrawCommandData> get copyWith => __$DrawCommandDataCopyWithImpl<_DrawCommandData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawCommandDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrawCommandData&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,toolName,layerId,const DeepCollectionEquality().hash(_points),strokeSettings,fillSettings);

@override
String toString() {
  return 'DrawCommand.data(toolName: $toolName, layerId: $layerId, points: $points, strokeSettings: $strokeSettings, fillSettings: $fillSettings)';
}


}

/// @nodoc
abstract mixin class _$DrawCommandDataCopyWith<$Res> implements $DrawCommandCopyWith<$Res> {
  factory _$DrawCommandDataCopyWith(_DrawCommandData value, $Res Function(_DrawCommandData) _then) = __$DrawCommandDataCopyWithImpl;
@override @useResult
$Res call({
 String toolName, String layerId,@OffsetConverter() List<Offset> points,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings
});




}
/// @nodoc
class __$DrawCommandDataCopyWithImpl<$Res>
    implements _$DrawCommandDataCopyWith<$Res> {
  __$DrawCommandDataCopyWithImpl(this._self, this._then);

  final _DrawCommandData _self;
  final $Res Function(_DrawCommandData) _then;

/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? toolName = null,Object? layerId = null,Object? points = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,}) {
  return _then(_DrawCommandData(
toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,
  ));
}


}

// dart format on
