// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'canvas_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CanvasData {

 String get id; String get name; List<String> get layerIds;
/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanvasDataCopyWith<CanvasData> get copyWith => _$CanvasDataCopyWithImpl<CanvasData>(this as CanvasData, _$identity);

  /// Serializes this CanvasData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.layerIds, layerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(layerIds));

@override
String toString() {
  return 'CanvasData(id: $id, name: $name, layerIds: $layerIds)';
}


}

/// @nodoc
abstract mixin class $CanvasDataCopyWith<$Res>  {
  factory $CanvasDataCopyWith(CanvasData value, $Res Function(CanvasData) _then) = _$CanvasDataCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> layerIds
});




}
/// @nodoc
class _$CanvasDataCopyWithImpl<$Res>
    implements $CanvasDataCopyWith<$Res> {
  _$CanvasDataCopyWithImpl(this._self, this._then);

  final CanvasData _self;
  final $Res Function(CanvasData) _then;

/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? layerIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layerIds: null == layerIds ? _self.layerIds : layerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CanvasData].
extension CanvasDataPatterns on CanvasData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CanvasData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CanvasData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CanvasData value)  $default,){
final _that = this;
switch (_that) {
case _CanvasData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CanvasData value)?  $default,){
final _that = this;
switch (_that) {
case _CanvasData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> layerIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CanvasData() when $default != null:
return $default(_that.id,_that.name,_that.layerIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> layerIds)  $default,) {final _that = this;
switch (_that) {
case _CanvasData():
return $default(_that.id,_that.name,_that.layerIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> layerIds)?  $default,) {final _that = this;
switch (_that) {
case _CanvasData() when $default != null:
return $default(_that.id,_that.name,_that.layerIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CanvasData implements CanvasData {
   _CanvasData({required this.id, required this.name, required final  List<String> layerIds}): _layerIds = layerIds;
  factory _CanvasData.fromJson(Map<String, dynamic> json) => _$CanvasDataFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _layerIds;
@override List<String> get layerIds {
  if (_layerIds is EqualUnmodifiableListView) return _layerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layerIds);
}


/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CanvasDataCopyWith<_CanvasData> get copyWith => __$CanvasDataCopyWithImpl<_CanvasData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanvasDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CanvasData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._layerIds, _layerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_layerIds));

@override
String toString() {
  return 'CanvasData(id: $id, name: $name, layerIds: $layerIds)';
}


}

/// @nodoc
abstract mixin class _$CanvasDataCopyWith<$Res> implements $CanvasDataCopyWith<$Res> {
  factory _$CanvasDataCopyWith(_CanvasData value, $Res Function(_CanvasData) _then) = __$CanvasDataCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> layerIds
});




}
/// @nodoc
class __$CanvasDataCopyWithImpl<$Res>
    implements _$CanvasDataCopyWith<$Res> {
  __$CanvasDataCopyWithImpl(this._self, this._then);

  final _CanvasData _self;
  final $Res Function(_CanvasData) _then;

/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? layerIds = null,}) {
  return _then(_CanvasData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layerIds: null == layerIds ? _self._layerIds : layerIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
