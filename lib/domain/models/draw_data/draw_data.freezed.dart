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
DrawData _$DrawDataFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'circle':
          return CircleData.fromJson(
            json
          );
                case 'freehand':
          return FreehandData.fromJson(
            json
          );
                case 'line':
          return LineData.fromJson(
            json
          );
                case 'path':
          return PathData.fromJson(
            json
          );
                case 'rectangle':
          return RectData.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'DrawData',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$DrawData {

 String get layerId; int get index; String get id;@PaintConverter() Paint get strokePaint; StrokeTypeOptions get strokeType;
/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawDataCopyWith<DrawData> get copyWith => _$DrawDataCopyWithImpl<DrawData>(this as DrawData, _$identity);

  /// Serializes this DrawData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,strokeType);

@override
String toString() {
  return 'DrawData(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, strokeType: $strokeType)';
}


}

/// @nodoc
abstract mixin class $DrawDataCopyWith<$Res>  {
  factory $DrawDataCopyWith(DrawData value, $Res Function(DrawData) _then) = _$DrawDataCopyWithImpl;
@useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint, StrokeTypeOptions strokeType
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
@pragma('vm:prefer-inline') @override $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? strokeType = null,}) {
  return _then(_self.copyWith(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CircleData value)?  circle,TResult Function( FreehandData value)?  freehand,TResult Function( LineData value)?  line,TResult Function( PathData value)?  path,TResult Function( RectData value)?  rectangle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CircleData() when circle != null:
return circle(_that);case FreehandData() when freehand != null:
return freehand(_that);case LineData() when line != null:
return line(_that);case PathData() when path != null:
return path(_that);case RectData() when rectangle != null:
return rectangle(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CircleData value)  circle,required TResult Function( FreehandData value)  freehand,required TResult Function( LineData value)  line,required TResult Function( PathData value)  path,required TResult Function( RectData value)  rectangle,}){
final _that = this;
switch (_that) {
case CircleData():
return circle(_that);case FreehandData():
return freehand(_that);case LineData():
return line(_that);case PathData():
return path(_that);case RectData():
return rectangle(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CircleData value)?  circle,TResult? Function( FreehandData value)?  freehand,TResult? Function( LineData value)?  line,TResult? Function( PathData value)?  path,TResult? Function( RectData value)?  rectangle,}){
final _that = this;
switch (_that) {
case CircleData() when circle != null:
return circle(_that);case FreehandData() when freehand != null:
return freehand(_that);case LineData() when line != null:
return line(_that);case PathData() when path != null:
return path(_that);case RectData() when rectangle != null:
return rectangle(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset center,  double radius,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  circle,TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType)?  freehand,TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  Offset startPoint, @OffsetConverter()  Offset endPoint,  StrokeTypeOptions strokeType)?  line,TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint,  bool closed, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  path,TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset topLeft, @OffsetConverter()  Offset botRight,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  rectangle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CircleData() when circle != null:
return circle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.center,_that.radius,_that.strokeType,_that.fillType);case FreehandData() when freehand != null:
return freehand(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.points,_that.strokeType);case LineData() when line != null:
return line(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.startPoint,_that.endPoint,_that.strokeType);case PathData() when path != null:
return path(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.closed,_that.points,_that.strokeType,_that.fillType);case RectData() when rectangle != null:
return rectangle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.topLeft,_that.botRight,_that.strokeType,_that.fillType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset center,  double radius,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)  circle,required TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType)  freehand,required TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  Offset startPoint, @OffsetConverter()  Offset endPoint,  StrokeTypeOptions strokeType)  line,required TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint,  bool closed, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)  path,required TResult Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset topLeft, @OffsetConverter()  Offset botRight,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)  rectangle,}) {final _that = this;
switch (_that) {
case CircleData():
return circle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.center,_that.radius,_that.strokeType,_that.fillType);case FreehandData():
return freehand(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.points,_that.strokeType);case LineData():
return line(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.startPoint,_that.endPoint,_that.strokeType);case PathData():
return path(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.closed,_that.points,_that.strokeType,_that.fillType);case RectData():
return rectangle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.topLeft,_that.botRight,_that.strokeType,_that.fillType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset center,  double radius,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  circle,TResult? Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType)?  freehand,TResult? Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @OffsetConverter()  Offset startPoint, @OffsetConverter()  Offset endPoint,  StrokeTypeOptions strokeType)?  line,TResult? Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint,  bool closed, @OffsetConverter()  List<Offset> points,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  path,TResult? Function( String layerId,  int index,  String id, @PaintConverter()  Paint strokePaint, @PaintConverter()  Paint fillPaint, @OffsetConverter()  Offset topLeft, @OffsetConverter()  Offset botRight,  StrokeTypeOptions strokeType,  FillTypeOptions fillType)?  rectangle,}) {final _that = this;
switch (_that) {
case CircleData() when circle != null:
return circle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.center,_that.radius,_that.strokeType,_that.fillType);case FreehandData() when freehand != null:
return freehand(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.points,_that.strokeType);case LineData() when line != null:
return line(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.startPoint,_that.endPoint,_that.strokeType);case PathData() when path != null:
return path(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.closed,_that.points,_that.strokeType,_that.fillType);case RectData() when rectangle != null:
return rectangle(_that.layerId,_that.index,_that.id,_that.strokePaint,_that.fillPaint,_that.topLeft,_that.botRight,_that.strokeType,_that.fillType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CircleData implements DrawData {
  const CircleData({required this.layerId, required this.index, required this.id, @PaintConverter() required this.strokePaint, @PaintConverter() required this.fillPaint, @OffsetConverter() required this.center, required this.radius, required this.strokeType, required this.fillType, final  String? $type}): $type = $type ?? 'circle';
  factory CircleData.fromJson(Map<String, dynamic> json) => _$CircleDataFromJson(json);

@override final  String layerId;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint strokePaint;
@PaintConverter() final  Paint fillPaint;
@OffsetConverter() final  Offset center;
 final  double radius;
@override final  StrokeTypeOptions strokeType;
 final  FillTypeOptions fillType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleDataCopyWith<CircleData> get copyWith => _$CircleDataCopyWithImpl<CircleData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CircleDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircleData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&(identical(other.fillPaint, fillPaint) || other.fillPaint == fillPaint)&&(identical(other.center, center) || other.center == center)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType)&&(identical(other.fillType, fillType) || other.fillType == fillType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,fillPaint,center,radius,strokeType,fillType);

@override
String toString() {
  return 'DrawData.circle(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, fillPaint: $fillPaint, center: $center, radius: $radius, strokeType: $strokeType, fillType: $fillType)';
}


}

/// @nodoc
abstract mixin class $CircleDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory $CircleDataCopyWith(CircleData value, $Res Function(CircleData) _then) = _$CircleDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint,@PaintConverter() Paint fillPaint,@OffsetConverter() Offset center, double radius, StrokeTypeOptions strokeType, FillTypeOptions fillType
});




}
/// @nodoc
class _$CircleDataCopyWithImpl<$Res>
    implements $CircleDataCopyWith<$Res> {
  _$CircleDataCopyWithImpl(this._self, this._then);

  final CircleData _self;
  final $Res Function(CircleData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? fillPaint = null,Object? center = null,Object? radius = null,Object? strokeType = null,Object? fillType = null,}) {
  return _then(CircleData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,fillPaint: null == fillPaint ? _self.fillPaint : fillPaint // ignore: cast_nullable_to_non_nullable
as Paint,center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as Offset,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,fillType: null == fillType ? _self.fillType : fillType // ignore: cast_nullable_to_non_nullable
as FillTypeOptions,
  ));
}


}

/// @nodoc
@JsonSerializable()

class FreehandData implements DrawData {
  const FreehandData({required this.layerId, required this.index, required this.id, @PaintConverter() required this.strokePaint, @OffsetConverter() required final  List<Offset> points, required this.strokeType, final  String? $type}): _points = points,$type = $type ?? 'freehand';
  factory FreehandData.fromJson(Map<String, dynamic> json) => _$FreehandDataFromJson(json);

@override final  String layerId;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint strokePaint;
 final  List<Offset> _points;
@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  StrokeTypeOptions strokeType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreehandDataCopyWith<FreehandData> get copyWith => _$FreehandDataCopyWithImpl<FreehandData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreehandDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreehandData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,const DeepCollectionEquality().hash(_points),strokeType);

@override
String toString() {
  return 'DrawData.freehand(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, points: $points, strokeType: $strokeType)';
}


}

/// @nodoc
abstract mixin class $FreehandDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory $FreehandDataCopyWith(FreehandData value, $Res Function(FreehandData) _then) = _$FreehandDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint,@OffsetConverter() List<Offset> points, StrokeTypeOptions strokeType
});




}
/// @nodoc
class _$FreehandDataCopyWithImpl<$Res>
    implements $FreehandDataCopyWith<$Res> {
  _$FreehandDataCopyWithImpl(this._self, this._then);

  final FreehandData _self;
  final $Res Function(FreehandData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? points = null,Object? strokeType = null,}) {
  return _then(FreehandData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,
  ));
}


}

/// @nodoc
@JsonSerializable()

class LineData implements DrawData {
  const LineData({required this.layerId, required this.index, required this.id, @PaintConverter() required this.strokePaint, @OffsetConverter() required this.startPoint, @OffsetConverter() required this.endPoint, required this.strokeType, final  String? $type}): $type = $type ?? 'line';
  factory LineData.fromJson(Map<String, dynamic> json) => _$LineDataFromJson(json);

@override final  String layerId;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint strokePaint;
@OffsetConverter() final  Offset startPoint;
@OffsetConverter() final  Offset endPoint;
@override final  StrokeTypeOptions strokeType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LineDataCopyWith<LineData> get copyWith => _$LineDataCopyWithImpl<LineData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LineDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LineData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&(identical(other.startPoint, startPoint) || other.startPoint == startPoint)&&(identical(other.endPoint, endPoint) || other.endPoint == endPoint)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,startPoint,endPoint,strokeType);

@override
String toString() {
  return 'DrawData.line(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, startPoint: $startPoint, endPoint: $endPoint, strokeType: $strokeType)';
}


}

/// @nodoc
abstract mixin class $LineDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory $LineDataCopyWith(LineData value, $Res Function(LineData) _then) = _$LineDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint,@OffsetConverter() Offset startPoint,@OffsetConverter() Offset endPoint, StrokeTypeOptions strokeType
});




}
/// @nodoc
class _$LineDataCopyWithImpl<$Res>
    implements $LineDataCopyWith<$Res> {
  _$LineDataCopyWithImpl(this._self, this._then);

  final LineData _self;
  final $Res Function(LineData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? startPoint = null,Object? endPoint = null,Object? strokeType = null,}) {
  return _then(LineData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,startPoint: null == startPoint ? _self.startPoint : startPoint // ignore: cast_nullable_to_non_nullable
as Offset,endPoint: null == endPoint ? _self.endPoint : endPoint // ignore: cast_nullable_to_non_nullable
as Offset,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PathData implements DrawData {
  const PathData({required this.layerId, required this.index, required this.id, @PaintConverter() required this.strokePaint, @PaintConverter() required this.fillPaint, this.closed = false, @OffsetConverter() required final  List<Offset> points, required this.strokeType, required this.fillType, final  String? $type}): _points = points,$type = $type ?? 'path';
  factory PathData.fromJson(Map<String, dynamic> json) => _$PathDataFromJson(json);

@override final  String layerId;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint strokePaint;
@PaintConverter() final  Paint fillPaint;
@JsonKey() final  bool closed;
 final  List<Offset> _points;
@OffsetConverter() List<Offset> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  StrokeTypeOptions strokeType;
 final  FillTypeOptions fillType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PathDataCopyWith<PathData> get copyWith => _$PathDataCopyWithImpl<PathData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PathDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PathData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&(identical(other.fillPaint, fillPaint) || other.fillPaint == fillPaint)&&(identical(other.closed, closed) || other.closed == closed)&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType)&&(identical(other.fillType, fillType) || other.fillType == fillType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,fillPaint,closed,const DeepCollectionEquality().hash(_points),strokeType,fillType);

@override
String toString() {
  return 'DrawData.path(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, fillPaint: $fillPaint, closed: $closed, points: $points, strokeType: $strokeType, fillType: $fillType)';
}


}

/// @nodoc
abstract mixin class $PathDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory $PathDataCopyWith(PathData value, $Res Function(PathData) _then) = _$PathDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint,@PaintConverter() Paint fillPaint, bool closed,@OffsetConverter() List<Offset> points, StrokeTypeOptions strokeType, FillTypeOptions fillType
});




}
/// @nodoc
class _$PathDataCopyWithImpl<$Res>
    implements $PathDataCopyWith<$Res> {
  _$PathDataCopyWithImpl(this._self, this._then);

  final PathData _self;
  final $Res Function(PathData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? fillPaint = null,Object? closed = null,Object? points = null,Object? strokeType = null,Object? fillType = null,}) {
  return _then(PathData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,fillPaint: null == fillPaint ? _self.fillPaint : fillPaint // ignore: cast_nullable_to_non_nullable
as Paint,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<Offset>,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,fillType: null == fillType ? _self.fillType : fillType // ignore: cast_nullable_to_non_nullable
as FillTypeOptions,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RectData implements DrawData {
  const RectData({required this.layerId, required this.index, required this.id, @PaintConverter() required this.strokePaint, @PaintConverter() required this.fillPaint, @OffsetConverter() required this.topLeft, @OffsetConverter() required this.botRight, required this.strokeType, required this.fillType, final  String? $type}): $type = $type ?? 'rectangle';
  factory RectData.fromJson(Map<String, dynamic> json) => _$RectDataFromJson(json);

@override final  String layerId;
@override final  int index;
@override final  String id;
@override@PaintConverter() final  Paint strokePaint;
@PaintConverter() final  Paint fillPaint;
@OffsetConverter() final  Offset topLeft;
@OffsetConverter() final  Offset botRight;
@override final  StrokeTypeOptions strokeType;
 final  FillTypeOptions fillType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RectDataCopyWith<RectData> get copyWith => _$RectDataCopyWithImpl<RectData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RectDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RectData&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.index, index) || other.index == index)&&(identical(other.id, id) || other.id == id)&&(identical(other.strokePaint, strokePaint) || other.strokePaint == strokePaint)&&(identical(other.fillPaint, fillPaint) || other.fillPaint == fillPaint)&&(identical(other.topLeft, topLeft) || other.topLeft == topLeft)&&(identical(other.botRight, botRight) || other.botRight == botRight)&&(identical(other.strokeType, strokeType) || other.strokeType == strokeType)&&(identical(other.fillType, fillType) || other.fillType == fillType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,layerId,index,id,strokePaint,fillPaint,topLeft,botRight,strokeType,fillType);

@override
String toString() {
  return 'DrawData.rectangle(layerId: $layerId, index: $index, id: $id, strokePaint: $strokePaint, fillPaint: $fillPaint, topLeft: $topLeft, botRight: $botRight, strokeType: $strokeType, fillType: $fillType)';
}


}

/// @nodoc
abstract mixin class $RectDataCopyWith<$Res> implements $DrawDataCopyWith<$Res> {
  factory $RectDataCopyWith(RectData value, $Res Function(RectData) _then) = _$RectDataCopyWithImpl;
@override @useResult
$Res call({
 String layerId, int index, String id,@PaintConverter() Paint strokePaint,@PaintConverter() Paint fillPaint,@OffsetConverter() Offset topLeft,@OffsetConverter() Offset botRight, StrokeTypeOptions strokeType, FillTypeOptions fillType
});




}
/// @nodoc
class _$RectDataCopyWithImpl<$Res>
    implements $RectDataCopyWith<$Res> {
  _$RectDataCopyWithImpl(this._self, this._then);

  final RectData _self;
  final $Res Function(RectData) _then;

/// Create a copy of DrawData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? index = null,Object? id = null,Object? strokePaint = null,Object? fillPaint = null,Object? topLeft = null,Object? botRight = null,Object? strokeType = null,Object? fillType = null,}) {
  return _then(RectData(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,strokePaint: null == strokePaint ? _self.strokePaint : strokePaint // ignore: cast_nullable_to_non_nullable
as Paint,fillPaint: null == fillPaint ? _self.fillPaint : fillPaint // ignore: cast_nullable_to_non_nullable
as Paint,topLeft: null == topLeft ? _self.topLeft : topLeft // ignore: cast_nullable_to_non_nullable
as Offset,botRight: null == botRight ? _self.botRight : botRight // ignore: cast_nullable_to_non_nullable
as Offset,strokeType: null == strokeType ? _self.strokeType : strokeType // ignore: cast_nullable_to_non_nullable
as StrokeTypeOptions,fillType: null == fillType ? _self.fillType : fillType // ignore: cast_nullable_to_non_nullable
as FillTypeOptions,
  ));
}


}

// dart format on
