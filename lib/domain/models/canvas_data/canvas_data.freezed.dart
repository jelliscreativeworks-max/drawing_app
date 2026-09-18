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
CanvasData _$CanvasDataFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'placeholder':
          return CanvasDataPlaceHolder.fromJson(
            json
          );
        
          default:
            return CanvasDataCreated.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$CanvasData {

 String get id; String get name; List<String> get layerIds;@SizeConverter() Size get canvasSize;
/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanvasDataCopyWith<CanvasData> get copyWith => _$CanvasDataCopyWithImpl<CanvasData>(this as CanvasData, _$identity);

  /// Serializes this CanvasData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasData&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.layerIds, layerIds)&&(identical(other.canvasSize, canvasSize) || other.canvasSize == canvasSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(layerIds),canvasSize);

@override
String toString() {
  return 'CanvasData(id: $id, name: $name, layerIds: $layerIds, canvasSize: $canvasSize)';
}


}

/// @nodoc
abstract mixin class $CanvasDataCopyWith<$Res>  {
  factory $CanvasDataCopyWith(CanvasData value, $Res Function(CanvasData) _then) = _$CanvasDataCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> layerIds,@SizeConverter() Size canvasSize
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? layerIds = null,Object? canvasSize = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layerIds: null == layerIds ? _self.layerIds : layerIds // ignore: cast_nullable_to_non_nullable
as List<String>,canvasSize: null == canvasSize ? _self.canvasSize : canvasSize // ignore: cast_nullable_to_non_nullable
as Size,
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( CanvasDataCreated value)?  $default,{TResult Function( CanvasDataPlaceHolder value)?  placeholder,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CanvasDataCreated() when $default != null:
return $default(_that);case CanvasDataPlaceHolder() when placeholder != null:
return placeholder(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( CanvasDataCreated value)  $default,{required TResult Function( CanvasDataPlaceHolder value)  placeholder,}){
final _that = this;
switch (_that) {
case CanvasDataCreated():
return $default(_that);case CanvasDataPlaceHolder():
return placeholder(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( CanvasDataCreated value)?  $default,{TResult? Function( CanvasDataPlaceHolder value)?  placeholder,}){
final _that = this;
switch (_that) {
case CanvasDataCreated() when $default != null:
return $default(_that);case CanvasDataPlaceHolder() when placeholder != null:
return placeholder(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)?  $default,{TResult Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)?  placeholder,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CanvasDataCreated() when $default != null:
return $default(_that.id,_that.name,_that.layerIds,_that.canvasSize);case CanvasDataPlaceHolder() when placeholder != null:
return placeholder(_that.id,_that.name,_that.layerIds,_that.canvasSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)  $default,{required TResult Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)  placeholder,}) {final _that = this;
switch (_that) {
case CanvasDataCreated():
return $default(_that.id,_that.name,_that.layerIds,_that.canvasSize);case CanvasDataPlaceHolder():
return placeholder(_that.id,_that.name,_that.layerIds,_that.canvasSize);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)?  $default,{TResult? Function( String id,  String name,  List<String> layerIds, @SizeConverter()  Size canvasSize)?  placeholder,}) {final _that = this;
switch (_that) {
case CanvasDataCreated() when $default != null:
return $default(_that.id,_that.name,_that.layerIds,_that.canvasSize);case CanvasDataPlaceHolder() when placeholder != null:
return placeholder(_that.id,_that.name,_that.layerIds,_that.canvasSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CanvasDataCreated extends CanvasData {
  const CanvasDataCreated({required this.id, required this.name, required final  List<String> layerIds, @SizeConverter() required this.canvasSize, final  String? $type}): _layerIds = layerIds,$type = $type ?? 'default',super._();
  factory CanvasDataCreated.fromJson(Map<String, dynamic> json) => _$CanvasDataCreatedFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _layerIds;
@override List<String> get layerIds {
  if (_layerIds is EqualUnmodifiableListView) return _layerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layerIds);
}

@override@SizeConverter() final  Size canvasSize;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanvasDataCreatedCopyWith<CanvasDataCreated> get copyWith => _$CanvasDataCreatedCopyWithImpl<CanvasDataCreated>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanvasDataCreatedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasDataCreated&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._layerIds, _layerIds)&&(identical(other.canvasSize, canvasSize) || other.canvasSize == canvasSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_layerIds),canvasSize);

@override
String toString() {
  return 'CanvasData(id: $id, name: $name, layerIds: $layerIds, canvasSize: $canvasSize)';
}


}

/// @nodoc
abstract mixin class $CanvasDataCreatedCopyWith<$Res> implements $CanvasDataCopyWith<$Res> {
  factory $CanvasDataCreatedCopyWith(CanvasDataCreated value, $Res Function(CanvasDataCreated) _then) = _$CanvasDataCreatedCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> layerIds,@SizeConverter() Size canvasSize
});




}
/// @nodoc
class _$CanvasDataCreatedCopyWithImpl<$Res>
    implements $CanvasDataCreatedCopyWith<$Res> {
  _$CanvasDataCreatedCopyWithImpl(this._self, this._then);

  final CanvasDataCreated _self;
  final $Res Function(CanvasDataCreated) _then;

/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? layerIds = null,Object? canvasSize = null,}) {
  return _then(CanvasDataCreated(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layerIds: null == layerIds ? _self._layerIds : layerIds // ignore: cast_nullable_to_non_nullable
as List<String>,canvasSize: null == canvasSize ? _self.canvasSize : canvasSize // ignore: cast_nullable_to_non_nullable
as Size,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CanvasDataPlaceHolder extends CanvasData {
  const CanvasDataPlaceHolder({this.id = '', this.name = 'untitled', final  List<String> layerIds = const [], @SizeConverter() this.canvasSize = const Size(2000, 2000), final  String? $type}): _layerIds = layerIds,$type = $type ?? 'placeholder',super._();
  factory CanvasDataPlaceHolder.fromJson(Map<String, dynamic> json) => _$CanvasDataPlaceHolderFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
 final  List<String> _layerIds;
@override@JsonKey() List<String> get layerIds {
  if (_layerIds is EqualUnmodifiableListView) return _layerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layerIds);
}

@override@JsonKey()@SizeConverter() final  Size canvasSize;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CanvasDataPlaceHolderCopyWith<CanvasDataPlaceHolder> get copyWith => _$CanvasDataPlaceHolderCopyWithImpl<CanvasDataPlaceHolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CanvasDataPlaceHolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CanvasDataPlaceHolder&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._layerIds, _layerIds)&&(identical(other.canvasSize, canvasSize) || other.canvasSize == canvasSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_layerIds),canvasSize);

@override
String toString() {
  return 'CanvasData.placeholder(id: $id, name: $name, layerIds: $layerIds, canvasSize: $canvasSize)';
}


}

/// @nodoc
abstract mixin class $CanvasDataPlaceHolderCopyWith<$Res> implements $CanvasDataCopyWith<$Res> {
  factory $CanvasDataPlaceHolderCopyWith(CanvasDataPlaceHolder value, $Res Function(CanvasDataPlaceHolder) _then) = _$CanvasDataPlaceHolderCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> layerIds,@SizeConverter() Size canvasSize
});




}
/// @nodoc
class _$CanvasDataPlaceHolderCopyWithImpl<$Res>
    implements $CanvasDataPlaceHolderCopyWith<$Res> {
  _$CanvasDataPlaceHolderCopyWithImpl(this._self, this._then);

  final CanvasDataPlaceHolder _self;
  final $Res Function(CanvasDataPlaceHolder) _then;

/// Create a copy of CanvasData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? layerIds = null,Object? canvasSize = null,}) {
  return _then(CanvasDataPlaceHolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layerIds: null == layerIds ? _self._layerIds : layerIds // ignore: cast_nullable_to_non_nullable
as List<String>,canvasSize: null == canvasSize ? _self.canvasSize : canvasSize // ignore: cast_nullable_to_non_nullable
as Size,
  ));
}


}

// dart format on
