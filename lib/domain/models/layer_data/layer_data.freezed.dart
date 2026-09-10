// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'layer_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LayerData {

 String get id; int get index; String get name; String get canvasId; double get opacity; bool get isDirty; bool get isVisible; List<DrawData> get layerDrawHistory;
/// Create a copy of LayerData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayerDataCopyWith<LayerData> get copyWith => _$LayerDataCopyWithImpl<LayerData>(this as LayerData, _$identity);

  /// Serializes this LayerData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayerData&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.canvasId, canvasId) || other.canvasId == canvasId)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&const DeepCollectionEquality().equals(other.layerDrawHistory, layerDrawHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,canvasId,opacity,isDirty,isVisible,const DeepCollectionEquality().hash(layerDrawHistory));

@override
String toString() {
  return 'LayerData(id: $id, index: $index, name: $name, canvasId: $canvasId, opacity: $opacity, isDirty: $isDirty, isVisible: $isVisible, layerDrawHistory: $layerDrawHistory)';
}


}

/// @nodoc
abstract mixin class $LayerDataCopyWith<$Res>  {
  factory $LayerDataCopyWith(LayerData value, $Res Function(LayerData) _then) = _$LayerDataCopyWithImpl;
@useResult
$Res call({
 String id, int index, String name, String canvasId, double opacity, bool isDirty, bool isVisible, List<DrawData> layerDrawHistory
});




}
/// @nodoc
class _$LayerDataCopyWithImpl<$Res>
    implements $LayerDataCopyWith<$Res> {
  _$LayerDataCopyWithImpl(this._self, this._then);

  final LayerData _self;
  final $Res Function(LayerData) _then;

/// Create a copy of LayerData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? index = null,Object? name = null,Object? canvasId = null,Object? opacity = null,Object? isDirty = null,Object? isVisible = null,Object? layerDrawHistory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,canvasId: null == canvasId ? _self.canvasId : canvasId // ignore: cast_nullable_to_non_nullable
as String,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,layerDrawHistory: null == layerDrawHistory ? _self.layerDrawHistory : layerDrawHistory // ignore: cast_nullable_to_non_nullable
as List<DrawData>,
  ));
}

}


/// Adds pattern-matching-related methods to [LayerData].
extension LayerDataPatterns on LayerData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayerData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayerData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayerData value)  $default,){
final _that = this;
switch (_that) {
case _LayerData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayerData value)?  $default,){
final _that = this;
switch (_that) {
case _LayerData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int index,  String name,  String canvasId,  double opacity,  bool isDirty,  bool isVisible,  List<DrawData> layerDrawHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayerData() when $default != null:
return $default(_that.id,_that.index,_that.name,_that.canvasId,_that.opacity,_that.isDirty,_that.isVisible,_that.layerDrawHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int index,  String name,  String canvasId,  double opacity,  bool isDirty,  bool isVisible,  List<DrawData> layerDrawHistory)  $default,) {final _that = this;
switch (_that) {
case _LayerData():
return $default(_that.id,_that.index,_that.name,_that.canvasId,_that.opacity,_that.isDirty,_that.isVisible,_that.layerDrawHistory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int index,  String name,  String canvasId,  double opacity,  bool isDirty,  bool isVisible,  List<DrawData> layerDrawHistory)?  $default,) {final _that = this;
switch (_that) {
case _LayerData() when $default != null:
return $default(_that.id,_that.index,_that.name,_that.canvasId,_that.opacity,_that.isDirty,_that.isVisible,_that.layerDrawHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LayerData implements LayerData {
   _LayerData({required this.id, required this.index, required this.name, required this.canvasId, this.opacity = 1.0, this.isDirty = true, this.isVisible = true, final  List<DrawData> layerDrawHistory = const <DrawData>[]}): _layerDrawHistory = layerDrawHistory;
  factory _LayerData.fromJson(Map<String, dynamic> json) => _$LayerDataFromJson(json);

@override final  String id;
@override final  int index;
@override final  String name;
@override final  String canvasId;
@override@JsonKey() final  double opacity;
@override@JsonKey() final  bool isDirty;
@override@JsonKey() final  bool isVisible;
 final  List<DrawData> _layerDrawHistory;
@override@JsonKey() List<DrawData> get layerDrawHistory {
  if (_layerDrawHistory is EqualUnmodifiableListView) return _layerDrawHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layerDrawHistory);
}


/// Create a copy of LayerData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayerDataCopyWith<_LayerData> get copyWith => __$LayerDataCopyWithImpl<_LayerData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LayerDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayerData&&(identical(other.id, id) || other.id == id)&&(identical(other.index, index) || other.index == index)&&(identical(other.name, name) || other.name == name)&&(identical(other.canvasId, canvasId) || other.canvasId == canvasId)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&const DeepCollectionEquality().equals(other._layerDrawHistory, _layerDrawHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,index,name,canvasId,opacity,isDirty,isVisible,const DeepCollectionEquality().hash(_layerDrawHistory));

@override
String toString() {
  return 'LayerData(id: $id, index: $index, name: $name, canvasId: $canvasId, opacity: $opacity, isDirty: $isDirty, isVisible: $isVisible, layerDrawHistory: $layerDrawHistory)';
}


}

/// @nodoc
abstract mixin class _$LayerDataCopyWith<$Res> implements $LayerDataCopyWith<$Res> {
  factory _$LayerDataCopyWith(_LayerData value, $Res Function(_LayerData) _then) = __$LayerDataCopyWithImpl;
@override @useResult
$Res call({
 String id, int index, String name, String canvasId, double opacity, bool isDirty, bool isVisible, List<DrawData> layerDrawHistory
});




}
/// @nodoc
class __$LayerDataCopyWithImpl<$Res>
    implements _$LayerDataCopyWith<$Res> {
  __$LayerDataCopyWithImpl(this._self, this._then);

  final _LayerData _self;
  final $Res Function(_LayerData) _then;

/// Create a copy of LayerData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? index = null,Object? name = null,Object? canvasId = null,Object? opacity = null,Object? isDirty = null,Object? isVisible = null,Object? layerDrawHistory = null,}) {
  return _then(_LayerData(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,canvasId: null == canvasId ? _self.canvasId : canvasId // ignore: cast_nullable_to_non_nullable
as String,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,layerDrawHistory: null == layerDrawHistory ? _self._layerDrawHistory : layerDrawHistory // ignore: cast_nullable_to_non_nullable
as List<DrawData>,
  ));
}


}

// dart format on
