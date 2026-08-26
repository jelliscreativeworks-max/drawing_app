// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draw_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrawLayer {

 int get zIndex; String get id; String get name; String get canvasId; bool get isDirty;@Uint8ListConverter() Uint8List? get layerSnapShot; List<DrawCommand> get layerDrawHistory; bool get isVisible;
/// Create a copy of DrawLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrawLayerCopyWith<DrawLayer> get copyWith => _$DrawLayerCopyWithImpl<DrawLayer>(this as DrawLayer, _$identity);

  /// Serializes this DrawLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrawLayer&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.canvasId, canvasId) || other.canvasId == canvasId)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&const DeepCollectionEquality().equals(other.layerSnapShot, layerSnapShot)&&const DeepCollectionEquality().equals(other.layerDrawHistory, layerDrawHistory)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zIndex,id,name,canvasId,isDirty,const DeepCollectionEquality().hash(layerSnapShot),const DeepCollectionEquality().hash(layerDrawHistory),isVisible);

@override
String toString() {
  return 'DrawLayer(zIndex: $zIndex, id: $id, name: $name, canvasId: $canvasId, isDirty: $isDirty, layerSnapShot: $layerSnapShot, layerDrawHistory: $layerDrawHistory, isVisible: $isVisible)';
}


}

/// @nodoc
abstract mixin class $DrawLayerCopyWith<$Res>  {
  factory $DrawLayerCopyWith(DrawLayer value, $Res Function(DrawLayer) _then) = _$DrawLayerCopyWithImpl;
@useResult
$Res call({
 int zIndex, String id, String name, String canvasId, bool isDirty,@Uint8ListConverter() Uint8List? layerSnapShot, List<DrawCommand> layerDrawHistory, bool isVisible
});




}
/// @nodoc
class _$DrawLayerCopyWithImpl<$Res>
    implements $DrawLayerCopyWith<$Res> {
  _$DrawLayerCopyWithImpl(this._self, this._then);

  final DrawLayer _self;
  final $Res Function(DrawLayer) _then;

/// Create a copy of DrawLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zIndex = null,Object? id = null,Object? name = null,Object? canvasId = null,Object? isDirty = null,Object? layerSnapShot = freezed,Object? layerDrawHistory = null,Object? isVisible = null,}) {
  return _then(_self.copyWith(
zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,canvasId: null == canvasId ? _self.canvasId : canvasId // ignore: cast_nullable_to_non_nullable
as String,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,layerSnapShot: freezed == layerSnapShot ? _self.layerSnapShot : layerSnapShot // ignore: cast_nullable_to_non_nullable
as Uint8List?,layerDrawHistory: null == layerDrawHistory ? _self.layerDrawHistory : layerDrawHistory // ignore: cast_nullable_to_non_nullable
as List<DrawCommand>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DrawLayer].
extension DrawLayerPatterns on DrawLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrawLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrawLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrawLayer value)  $default,){
final _that = this;
switch (_that) {
case _DrawLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrawLayer value)?  $default,){
final _that = this;
switch (_that) {
case _DrawLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int zIndex,  String id,  String name,  String canvasId,  bool isDirty, @Uint8ListConverter()  Uint8List? layerSnapShot,  List<DrawCommand> layerDrawHistory,  bool isVisible)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrawLayer() when $default != null:
return $default(_that.zIndex,_that.id,_that.name,_that.canvasId,_that.isDirty,_that.layerSnapShot,_that.layerDrawHistory,_that.isVisible);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int zIndex,  String id,  String name,  String canvasId,  bool isDirty, @Uint8ListConverter()  Uint8List? layerSnapShot,  List<DrawCommand> layerDrawHistory,  bool isVisible)  $default,) {final _that = this;
switch (_that) {
case _DrawLayer():
return $default(_that.zIndex,_that.id,_that.name,_that.canvasId,_that.isDirty,_that.layerSnapShot,_that.layerDrawHistory,_that.isVisible);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int zIndex,  String id,  String name,  String canvasId,  bool isDirty, @Uint8ListConverter()  Uint8List? layerSnapShot,  List<DrawCommand> layerDrawHistory,  bool isVisible)?  $default,) {final _that = this;
switch (_that) {
case _DrawLayer() when $default != null:
return $default(_that.zIndex,_that.id,_that.name,_that.canvasId,_that.isDirty,_that.layerSnapShot,_that.layerDrawHistory,_that.isVisible);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DrawLayer implements DrawLayer {
   _DrawLayer({required this.zIndex, required this.id, required this.name, required this.canvasId, this.isDirty = true, @Uint8ListConverter() this.layerSnapShot, final  List<DrawCommand> layerDrawHistory = const <DrawCommand>[], this.isVisible = true}): _layerDrawHistory = layerDrawHistory;
  factory _DrawLayer.fromJson(Map<String, dynamic> json) => _$DrawLayerFromJson(json);

@override final  int zIndex;
@override final  String id;
@override final  String name;
@override final  String canvasId;
@override@JsonKey() final  bool isDirty;
@override@Uint8ListConverter() final  Uint8List? layerSnapShot;
 final  List<DrawCommand> _layerDrawHistory;
@override@JsonKey() List<DrawCommand> get layerDrawHistory {
  if (_layerDrawHistory is EqualUnmodifiableListView) return _layerDrawHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layerDrawHistory);
}

@override@JsonKey() final  bool isVisible;

/// Create a copy of DrawLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrawLayerCopyWith<_DrawLayer> get copyWith => __$DrawLayerCopyWithImpl<_DrawLayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrawLayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrawLayer&&(identical(other.zIndex, zIndex) || other.zIndex == zIndex)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.canvasId, canvasId) || other.canvasId == canvasId)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&const DeepCollectionEquality().equals(other.layerSnapShot, layerSnapShot)&&const DeepCollectionEquality().equals(other._layerDrawHistory, _layerDrawHistory)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,zIndex,id,name,canvasId,isDirty,const DeepCollectionEquality().hash(layerSnapShot),const DeepCollectionEquality().hash(_layerDrawHistory),isVisible);

@override
String toString() {
  return 'DrawLayer(zIndex: $zIndex, id: $id, name: $name, canvasId: $canvasId, isDirty: $isDirty, layerSnapShot: $layerSnapShot, layerDrawHistory: $layerDrawHistory, isVisible: $isVisible)';
}


}

/// @nodoc
abstract mixin class _$DrawLayerCopyWith<$Res> implements $DrawLayerCopyWith<$Res> {
  factory _$DrawLayerCopyWith(_DrawLayer value, $Res Function(_DrawLayer) _then) = __$DrawLayerCopyWithImpl;
@override @useResult
$Res call({
 int zIndex, String id, String name, String canvasId, bool isDirty,@Uint8ListConverter() Uint8List? layerSnapShot, List<DrawCommand> layerDrawHistory, bool isVisible
});




}
/// @nodoc
class __$DrawLayerCopyWithImpl<$Res>
    implements _$DrawLayerCopyWith<$Res> {
  __$DrawLayerCopyWithImpl(this._self, this._then);

  final _DrawLayer _self;
  final $Res Function(_DrawLayer) _then;

/// Create a copy of DrawLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zIndex = null,Object? id = null,Object? name = null,Object? canvasId = null,Object? isDirty = null,Object? layerSnapShot = freezed,Object? layerDrawHistory = null,Object? isVisible = null,}) {
  return _then(_DrawLayer(
zIndex: null == zIndex ? _self.zIndex : zIndex // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,canvasId: null == canvasId ? _self.canvasId : canvasId // ignore: cast_nullable_to_non_nullable
as String,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,layerSnapShot: freezed == layerSnapShot ? _self.layerSnapShot : layerSnapShot // ignore: cast_nullable_to_non_nullable
as Uint8List?,layerDrawHistory: null == layerDrawHistory ? _self._layerDrawHistory : layerDrawHistory // ignore: cast_nullable_to_non_nullable
as List<DrawCommand>,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
