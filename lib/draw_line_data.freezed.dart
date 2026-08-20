// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draw_line_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrawLine {

@OffsetConverter() List<Offset> get points;@ColorConverter() Color get strokeColor; StrokeCap get strokeCap; double get strokeWidth;
/// Create a copy of DrawLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawLineCopyWith<DrawLine> get copyWith => _$DrawLineCopyWithImpl<DrawLine>(this as DrawLine, _$identity);

  /// Serializes this DrawLine to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawLine&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.strokeColor, strokeColor) || other.strokeColor == strokeColor)&&(identical(other.strokeCap, strokeCap) || other.strokeCap == strokeCap)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),strokeColor,strokeCap,strokeWidth);

@override
String toString() {
  return 'DrawLine(points: $points, strokeColor: $strokeColor, strokeCap: $strokeCap, strokeWidth: $strokeWidth)';
}


}

/// @nodoc
abstract mixin class $DrawLineCopyWith<$Res>  {
  factory $DrawLineCopyWith(DrawLine value, $Res Function(DrawLine) _then) = _$DrawLineCopyWithImpl;
@useResult
$Res call({
@OffsetConverter() List<Offset> points,@ColorConverter() Color strokeColor, StrokeCap strokeCap, double strokeWidth
});




}
/// @nodoc
class _$DrawLineCopyWithImpl<$Res>
    implements $DrawLineCopyWith<$Res> {
  _$DrawLineCopyWithImpl(this._self, this._then);

  final DrawLine _self;
  final $Res Function(DrawLine) _then;

/// Create a copy of DrawLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? strokeColor = null,Object? strokeCap = null,Object? strokeWidth = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeColor: null == strokeColor ? _self.strokeColor : strokeColor // ignore: cast_nullable_to_non_nullable
as Color,strokeCap: null == strokeCap ? _self.strokeCap : strokeCap // ignore: cast_nullable_to_non_nullable
as StrokeCap,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DrawLine].
extension DrawLinePatterns on DrawLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrawLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrawLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrawLine value)  $default,){
final _that = this;
switch (_that) {
case _DrawLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrawLine value)?  $default,){
final _that = this;
switch (_that) {
case _DrawLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@OffsetConverter()  List<Offset> points, @ColorConverter()  Color strokeColor,  StrokeCap strokeCap,  double strokeWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrawLine() when $default != null:
return $default(_that.points,_that.strokeColor,_that.strokeCap,_that.strokeWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@OffsetConverter()  List<Offset> points, @ColorConverter()  Color strokeColor,  StrokeCap strokeCap,  double strokeWidth)  $default,) {final _that = this;
switch (_that) {
case _DrawLine():
return $default(_that.points,_that.strokeColor,_that.strokeCap,_that.strokeWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@OffsetConverter()  List<Offset> points, @ColorConverter()  Color strokeColor,  StrokeCap strokeCap,  double strokeWidth)?  $default,) {final _that = this;
switch (_that) {
case _DrawLine() when $default != null:
return $default(_that.points,_that.strokeColor,_that.strokeCap,_that.strokeWidth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrawLine implements DrawLine {
  const _DrawLine({@OffsetConverter() required final  List<Offset> points, @ColorConverter() required this.strokeColor, required this.strokeCap, required this.strokeWidth}): _points = points;
  factory _DrawLine.fromJson(Map<String, dynamic> json) => _$DrawLineFromJson(json);

 final  List<Offset> _points;
@override@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override@ColorConverter() final  Color strokeColor;
@override final  StrokeCap strokeCap;
@override final  double strokeWidth;

/// Create a copy of DrawLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawLineCopyWith<_DrawLine> get copyWith => __$DrawLineCopyWithImpl<_DrawLine>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawLineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrawLine&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.strokeColor, strokeColor) || other.strokeColor == strokeColor)&&(identical(other.strokeCap, strokeCap) || other.strokeCap == strokeCap)&&(identical(other.strokeWidth, strokeWidth) || other.strokeWidth == strokeWidth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),strokeColor,strokeCap,strokeWidth);

@override
String toString() {
  return 'DrawLine(points: $points, strokeColor: $strokeColor, strokeCap: $strokeCap, strokeWidth: $strokeWidth)';
}


}

/// @nodoc
abstract mixin class _$DrawLineCopyWith<$Res> implements $DrawLineCopyWith<$Res> {
  factory _$DrawLineCopyWith(_DrawLine value, $Res Function(_DrawLine) _then) = __$DrawLineCopyWithImpl;
@override @useResult
$Res call({
@OffsetConverter() List<Offset> points,@ColorConverter() Color strokeColor, StrokeCap strokeCap, double strokeWidth
});




}
/// @nodoc
class __$DrawLineCopyWithImpl<$Res>
    implements _$DrawLineCopyWith<$Res> {
  __$DrawLineCopyWithImpl(this._self, this._then);

  final _DrawLine _self;
  final $Res Function(_DrawLine) _then;

/// Create a copy of DrawLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? strokeColor = null,Object? strokeCap = null,Object? strokeWidth = null,}) {
  return _then(_DrawLine(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeColor: null == strokeColor ? _self.strokeColor : strokeColor // ignore: cast_nullable_to_non_nullable
as Color,strokeCap: null == strokeCap ? _self.strokeCap : strokeCap // ignore: cast_nullable_to_non_nullable
as StrokeCap,strokeWidth: null == strokeWidth ? _self.strokeWidth : strokeWidth // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
