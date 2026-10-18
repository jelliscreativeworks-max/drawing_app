// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PropertyData<T> {

 Object? get value; PropertyId<dynamic> get id;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyData<T>&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value),id);

@override
String toString() {
  return 'PropertyData<$T>(value: $value, id: $id)';
}


}

/// @nodoc
class $PropertyDataCopyWith<T,$Res>  {
$PropertyDataCopyWith(PropertyData<T> _, $Res Function(PropertyData<T>) __);
}


/// Adds pattern-matching-related methods to [PropertyData].
extension PropertyDataPatterns<T> on PropertyData<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ColorPropertyData<T> value)?  color,TResult Function( TogglePropertyData<T> value)?  toggle,TResult Function( ChoicePropertyData<T> value)?  choice,TResult Function( StringPropertyData<T> value)?  string,TResult Function( DoublePropertyData<T> value)?  double,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that);case TogglePropertyData() when toggle != null:
return toggle(_that);case ChoicePropertyData() when choice != null:
return choice(_that);case StringPropertyData() when string != null:
return string(_that);case DoublePropertyData() when double != null:
return double(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ColorPropertyData<T> value)  color,required TResult Function( TogglePropertyData<T> value)  toggle,required TResult Function( ChoicePropertyData<T> value)  choice,required TResult Function( StringPropertyData<T> value)  string,required TResult Function( DoublePropertyData<T> value)  double,}){
final _that = this;
switch (_that) {
case ColorPropertyData():
return color(_that);case TogglePropertyData():
return toggle(_that);case ChoicePropertyData():
return choice(_that);case StringPropertyData():
return string(_that);case DoublePropertyData():
return double(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ColorPropertyData<T> value)?  color,TResult? Function( TogglePropertyData<T> value)?  toggle,TResult? Function( ChoicePropertyData<T> value)?  choice,TResult? Function( StringPropertyData<T> value)?  string,TResult? Function( DoublePropertyData<T> value)?  double,}){
final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that);case TogglePropertyData() when toggle != null:
return toggle(_that);case ChoicePropertyData() when choice != null:
return choice(_that);case StringPropertyData() when string != null:
return string(_that);case DoublePropertyData() when double != null:
return double(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Color value,  PropertyId<Color> id)?  color,TResult Function( bool value,  PropertyId<bool> id)?  toggle,TResult Function( T value,  List<T> options,  PropertyId id)?  choice,TResult Function( String value,  PropertyId<String> id)?  string,TResult Function( double value,  double maxValue,  double minValue,  PropertyId<double> id)?  double,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that.value,_that.id);case TogglePropertyData() when toggle != null:
return toggle(_that.value,_that.id);case ChoicePropertyData() when choice != null:
return choice(_that.value,_that.options,_that.id);case StringPropertyData() when string != null:
return string(_that.value,_that.id);case DoublePropertyData() when double != null:
return double(_that.value,_that.maxValue,_that.minValue,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Color value,  PropertyId<Color> id)  color,required TResult Function( bool value,  PropertyId<bool> id)  toggle,required TResult Function( T value,  List<T> options,  PropertyId id)  choice,required TResult Function( String value,  PropertyId<String> id)  string,required TResult Function( double value,  double maxValue,  double minValue,  PropertyId<double> id)  double,}) {final _that = this;
switch (_that) {
case ColorPropertyData():
return color(_that.value,_that.id);case TogglePropertyData():
return toggle(_that.value,_that.id);case ChoicePropertyData():
return choice(_that.value,_that.options,_that.id);case StringPropertyData():
return string(_that.value,_that.id);case DoublePropertyData():
return double(_that.value,_that.maxValue,_that.minValue,_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Color value,  PropertyId<Color> id)?  color,TResult? Function( bool value,  PropertyId<bool> id)?  toggle,TResult? Function( T value,  List<T> options,  PropertyId id)?  choice,TResult? Function( String value,  PropertyId<String> id)?  string,TResult? Function( double value,  double maxValue,  double minValue,  PropertyId<double> id)?  double,}) {final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that.value,_that.id);case TogglePropertyData() when toggle != null:
return toggle(_that.value,_that.id);case ChoicePropertyData() when choice != null:
return choice(_that.value,_that.options,_that.id);case StringPropertyData() when string != null:
return string(_that.value,_that.id);case DoublePropertyData() when double != null:
return double(_that.value,_that.maxValue,_that.minValue,_that.id);case _:
  return null;

}
}

}

/// @nodoc


class ColorPropertyData<T> extends PropertyData<T> {
   ColorPropertyData({required this.value, required this.id}): super._();
  

@override final  Color value;
@override final  PropertyId<Color> id;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorPropertyDataCopyWith<T, ColorPropertyData<T>> get copyWith => _$ColorPropertyDataCopyWithImpl<T, ColorPropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorPropertyData<T>&&(identical(other.value, value) || other.value == value)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,id);

@override
String toString() {
  return 'PropertyData<$T>.color(value: $value, id: $id)';
}


}

/// @nodoc
abstract mixin class $ColorPropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $ColorPropertyDataCopyWith(ColorPropertyData<T> value, $Res Function(ColorPropertyData<T>) _then) = _$ColorPropertyDataCopyWithImpl;
@useResult
$Res call({
 Color value, PropertyId<Color> id
});




}
/// @nodoc
class _$ColorPropertyDataCopyWithImpl<T,$Res>
    implements $ColorPropertyDataCopyWith<T, $Res> {
  _$ColorPropertyDataCopyWithImpl(this._self, this._then);

  final ColorPropertyData<T> _self;
  final $Res Function(ColorPropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,Object? id = null,}) {
  return _then(ColorPropertyData<T>(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Color,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PropertyId<Color>,
  ));
}


}

/// @nodoc


class TogglePropertyData<T> extends PropertyData<T> {
   TogglePropertyData({required this.value, required this.id}): super._();
  

@override final  bool value;
@override final  PropertyId<bool> id;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TogglePropertyDataCopyWith<T, TogglePropertyData<T>> get copyWith => _$TogglePropertyDataCopyWithImpl<T, TogglePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TogglePropertyData<T>&&(identical(other.value, value) || other.value == value)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,id);

@override
String toString() {
  return 'PropertyData<$T>.toggle(value: $value, id: $id)';
}


}

/// @nodoc
abstract mixin class $TogglePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $TogglePropertyDataCopyWith(TogglePropertyData<T> value, $Res Function(TogglePropertyData<T>) _then) = _$TogglePropertyDataCopyWithImpl;
@useResult
$Res call({
 bool value, PropertyId<bool> id
});




}
/// @nodoc
class _$TogglePropertyDataCopyWithImpl<T,$Res>
    implements $TogglePropertyDataCopyWith<T, $Res> {
  _$TogglePropertyDataCopyWithImpl(this._self, this._then);

  final TogglePropertyData<T> _self;
  final $Res Function(TogglePropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,Object? id = null,}) {
  return _then(TogglePropertyData<T>(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PropertyId<bool>,
  ));
}


}

/// @nodoc


class ChoicePropertyData<T> extends PropertyData<T> {
   ChoicePropertyData({required this.value, required final  List<T> options, required this.id}): _options = options,super._();
  

@override final  T value;
 final  List<T> _options;
 List<T> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override final  PropertyId id;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoicePropertyDataCopyWith<T, ChoicePropertyData<T>> get copyWith => _$ChoicePropertyDataCopyWithImpl<T, ChoicePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoicePropertyData<T>&&const DeepCollectionEquality().equals(other.value, value)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value),const DeepCollectionEquality().hash(_options),id);

@override
String toString() {
  return 'PropertyData<$T>.choice(value: $value, options: $options, id: $id)';
}


}

/// @nodoc
abstract mixin class $ChoicePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $ChoicePropertyDataCopyWith(ChoicePropertyData<T> value, $Res Function(ChoicePropertyData<T>) _then) = _$ChoicePropertyDataCopyWithImpl;
@useResult
$Res call({
 T value, List<T> options, PropertyId id
});




}
/// @nodoc
class _$ChoicePropertyDataCopyWithImpl<T,$Res>
    implements $ChoicePropertyDataCopyWith<T, $Res> {
  _$ChoicePropertyDataCopyWithImpl(this._self, this._then);

  final ChoicePropertyData<T> _self;
  final $Res Function(ChoicePropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,Object? options = null,Object? id = null,}) {
  return _then(ChoicePropertyData<T>(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<T>,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PropertyId,
  ));
}


}

/// @nodoc


class StringPropertyData<T> extends PropertyData<T> {
   StringPropertyData({required this.value, required this.id}): super._();
  

@override final  String value;
@override final  PropertyId<String> id;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StringPropertyDataCopyWith<T, StringPropertyData<T>> get copyWith => _$StringPropertyDataCopyWithImpl<T, StringPropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StringPropertyData<T>&&(identical(other.value, value) || other.value == value)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,id);

@override
String toString() {
  return 'PropertyData<$T>.string(value: $value, id: $id)';
}


}

/// @nodoc
abstract mixin class $StringPropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $StringPropertyDataCopyWith(StringPropertyData<T> value, $Res Function(StringPropertyData<T>) _then) = _$StringPropertyDataCopyWithImpl;
@useResult
$Res call({
 String value, PropertyId<String> id
});




}
/// @nodoc
class _$StringPropertyDataCopyWithImpl<T,$Res>
    implements $StringPropertyDataCopyWith<T, $Res> {
  _$StringPropertyDataCopyWithImpl(this._self, this._then);

  final StringPropertyData<T> _self;
  final $Res Function(StringPropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,Object? id = null,}) {
  return _then(StringPropertyData<T>(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PropertyId<String>,
  ));
}


}

/// @nodoc


class DoublePropertyData<T> extends PropertyData<T> {
   DoublePropertyData({required this.value, required this.maxValue, required this.minValue, required this.id}): super._();
  

@override final  double value;
 final  double maxValue;
 final  double minValue;
@override final  PropertyId<double> id;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoublePropertyDataCopyWith<T, DoublePropertyData<T>> get copyWith => _$DoublePropertyDataCopyWithImpl<T, DoublePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoublePropertyData<T>&&(identical(other.value, value) || other.value == value)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,value,maxValue,minValue,id);

@override
String toString() {
  return 'PropertyData<$T>.double(value: $value, maxValue: $maxValue, minValue: $minValue, id: $id)';
}


}

/// @nodoc
abstract mixin class $DoublePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $DoublePropertyDataCopyWith(DoublePropertyData<T> value, $Res Function(DoublePropertyData<T>) _then) = _$DoublePropertyDataCopyWithImpl;
@useResult
$Res call({
 double value, double maxValue, double minValue, PropertyId<double> id
});




}
/// @nodoc
class _$DoublePropertyDataCopyWithImpl<T,$Res>
    implements $DoublePropertyDataCopyWith<T, $Res> {
  _$DoublePropertyDataCopyWithImpl(this._self, this._then);

  final DoublePropertyData<T> _self;
  final $Res Function(DoublePropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,Object? maxValue = null,Object? minValue = null,Object? id = null,}) {
  return _then(DoublePropertyData<T>(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,maxValue: null == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double,minValue: null == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PropertyId<double>,
  ));
}


}

// dart format on
