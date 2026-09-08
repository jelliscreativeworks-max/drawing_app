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

/// @nodoc
mixin _$DrawCommand {

 String get layerId; String get toolName;@PaintConverter() Paint? get strokeSettings;@PaintConverter() Paint? get fillSettings;@OffsetConverter() List<Offset> get points;
/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawCommandCopyWith<DrawCommand> get copyWith => _$DrawCommandCopyWithImpl<DrawCommand>(this as DrawCommand, _$identity);

  /// Serializes this DrawCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawCommand&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,strokeSettings,fillSettings,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'DrawCommand(layerId: $layerId, toolName: $toolName, strokeSettings: $strokeSettings, fillSettings: $fillSettings, points: $points)';
}


}

/// @nodoc
abstract mixin class $DrawCommandCopyWith<$Res>  {
  factory $DrawCommandCopyWith(DrawCommand value, $Res Function(DrawCommand) _then) = _$DrawCommandCopyWithImpl;
@useResult
$Res call({
 String layerId, String toolName,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings,@OffsetConverter() List<Offset> points
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
@pragma('vm:prefer-inline') @override $Res call({Object? layerId = null,Object? toolName = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,Object? points = null,}) {
  return _then(_self.copyWith(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrawCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrawCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrawCommand value)  $default,){
final _that = this;
switch (_that) {
case _DrawCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrawCommand value)?  $default,){
final _that = this;
switch (_that) {
case _DrawCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String layerId,  String toolName, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrawCommand() when $default != null:
return $default(_that.layerId,_that.toolName,_that.strokeSettings,_that.fillSettings,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String layerId,  String toolName, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)  $default,) {final _that = this;
switch (_that) {
case _DrawCommand():
return $default(_that.layerId,_that.toolName,_that.strokeSettings,_that.fillSettings,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String layerId,  String toolName, @PaintConverter()  Paint? strokeSettings, @PaintConverter()  Paint? fillSettings, @OffsetConverter()  List<Offset> points)?  $default,) {final _that = this;
switch (_that) {
case _DrawCommand() when $default != null:
return $default(_that.layerId,_that.toolName,_that.strokeSettings,_that.fillSettings,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrawCommand extends DrawCommand {
  const _DrawCommand({required final  String layerId, required final  String toolName, @PaintConverter() this.strokeSettings, @PaintConverter() this.fillSettings, @OffsetConverter() required final  List<Offset> points}): _points = points,super._(layerId: layerId, toolName: toolName);
  factory _DrawCommand.fromJson(Map<String, dynamic> json) => _$DrawCommandFromJson(json);

@override@PaintConverter() final  Paint? strokeSettings;
@override@PaintConverter() final  Paint? fillSettings;
 final  List<Offset> _points;
@override@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawCommandCopyWith<_DrawCommand> get copyWith => __$DrawCommandCopyWithImpl<_DrawCommand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawCommandToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrawCommand&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&(identical(other.strokeSettings, strokeSettings) || other.strokeSettings == strokeSettings)&&(identical(other.fillSettings, fillSettings) || other.fillSettings == fillSettings)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,strokeSettings,fillSettings,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'DrawCommand(layerId: $layerId, toolName: $toolName, strokeSettings: $strokeSettings, fillSettings: $fillSettings, points: $points)';
}


}

/// @nodoc
abstract mixin class _$DrawCommandCopyWith<$Res> implements $DrawCommandCopyWith<$Res> {
  factory _$DrawCommandCopyWith(_DrawCommand value, $Res Function(_DrawCommand) _then) = __$DrawCommandCopyWithImpl;
@override @useResult
$Res call({
 String layerId, String toolName,@PaintConverter() Paint? strokeSettings,@PaintConverter() Paint? fillSettings,@OffsetConverter() List<Offset> points
});




}
/// @nodoc
class __$DrawCommandCopyWithImpl<$Res>
    implements _$DrawCommandCopyWith<$Res> {
  __$DrawCommandCopyWithImpl(this._self, this._then);

  final _DrawCommand _self;
  final $Res Function(_DrawCommand) _then;

/// Create a copy of DrawCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? toolName = null,Object? strokeSettings = freezed,Object? fillSettings = freezed,Object? points = null,}) {
  return _then(_DrawCommand(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,strokeSettings: freezed == strokeSettings ? _self.strokeSettings : strokeSettings // ignore: cast_nullable_to_non_nullable
as Paint?,fillSettings: freezed == fillSettings ? _self.fillSettings : fillSettings // ignore: cast_nullable_to_non_nullable
as Paint?,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,
  ));
}


}

// dart format on
