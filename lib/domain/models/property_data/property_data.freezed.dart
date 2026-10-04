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

 String get displayName; Object? get value; void Function(Never) get onChanged;
/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyDataCopyWith<T, PropertyData<T>> get copyWith => _$PropertyDataCopyWithImpl<T, PropertyData<T>>(this as PropertyData<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertyData<T>&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.value, value)&&(identical(other.onChanged, onChanged) || other.onChanged == onChanged));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,const DeepCollectionEquality().hash(value),onChanged);

@override
String toString() {
  return 'PropertyData<$T>(displayName: $displayName, value: $value, onChanged: $onChanged)';
}


}

/// @nodoc
abstract mixin class $PropertyDataCopyWith<T,$Res>  {
  factory $PropertyDataCopyWith(PropertyData<T> value, $Res Function(PropertyData<T>) _then) = _$PropertyDataCopyWithImpl;
@useResult
$Res call({
 String displayName
});




}
/// @nodoc
class _$PropertyDataCopyWithImpl<T,$Res>
    implements $PropertyDataCopyWith<T, $Res> {
  _$PropertyDataCopyWithImpl(this._self, this._then);

  final PropertyData<T> _self;
  final $Res Function(PropertyData<T>) _then;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ColorPropertyData<T> value)?  color,TResult Function( TogglePropertyData<T> value)?  toggle,TResult Function( ChoicePropertyData<T> value)?  choice,TResult Function( DoublePropertyData<T> value)?  double,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that);case TogglePropertyData() when toggle != null:
return toggle(_that);case ChoicePropertyData() when choice != null:
return choice(_that);case DoublePropertyData() when double != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ColorPropertyData<T> value)  color,required TResult Function( TogglePropertyData<T> value)  toggle,required TResult Function( ChoicePropertyData<T> value)  choice,required TResult Function( DoublePropertyData<T> value)  double,}){
final _that = this;
switch (_that) {
case ColorPropertyData():
return color(_that);case TogglePropertyData():
return toggle(_that);case ChoicePropertyData():
return choice(_that);case DoublePropertyData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ColorPropertyData<T> value)?  color,TResult? Function( TogglePropertyData<T> value)?  toggle,TResult? Function( ChoicePropertyData<T> value)?  choice,TResult? Function( DoublePropertyData<T> value)?  double,}){
final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that);case TogglePropertyData() when toggle != null:
return toggle(_that);case ChoicePropertyData() when choice != null:
return choice(_that);case DoublePropertyData() when double != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String displayName,  Color value,  ValueChanged<Color> onChanged)?  color,TResult Function( String displayName,  bool value,  ValueChanged<bool> onChanged)?  toggle,TResult Function( String displayName,  T value,  Map<Widget, T> options,  ValueChanged<T> onChanged)?  choice,TResult Function( String displayName,  double value,  ValueChanged<double> onChanged)?  double,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that.displayName,_that.value,_that.onChanged);case TogglePropertyData() when toggle != null:
return toggle(_that.displayName,_that.value,_that.onChanged);case ChoicePropertyData() when choice != null:
return choice(_that.displayName,_that.value,_that.options,_that.onChanged);case DoublePropertyData() when double != null:
return double(_that.displayName,_that.value,_that.onChanged);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String displayName,  Color value,  ValueChanged<Color> onChanged)  color,required TResult Function( String displayName,  bool value,  ValueChanged<bool> onChanged)  toggle,required TResult Function( String displayName,  T value,  Map<Widget, T> options,  ValueChanged<T> onChanged)  choice,required TResult Function( String displayName,  double value,  ValueChanged<double> onChanged)  double,}) {final _that = this;
switch (_that) {
case ColorPropertyData():
return color(_that.displayName,_that.value,_that.onChanged);case TogglePropertyData():
return toggle(_that.displayName,_that.value,_that.onChanged);case ChoicePropertyData():
return choice(_that.displayName,_that.value,_that.options,_that.onChanged);case DoublePropertyData():
return double(_that.displayName,_that.value,_that.onChanged);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String displayName,  Color value,  ValueChanged<Color> onChanged)?  color,TResult? Function( String displayName,  bool value,  ValueChanged<bool> onChanged)?  toggle,TResult? Function( String displayName,  T value,  Map<Widget, T> options,  ValueChanged<T> onChanged)?  choice,TResult? Function( String displayName,  double value,  ValueChanged<double> onChanged)?  double,}) {final _that = this;
switch (_that) {
case ColorPropertyData() when color != null:
return color(_that.displayName,_that.value,_that.onChanged);case TogglePropertyData() when toggle != null:
return toggle(_that.displayName,_that.value,_that.onChanged);case ChoicePropertyData() when choice != null:
return choice(_that.displayName,_that.value,_that.options,_that.onChanged);case DoublePropertyData() when double != null:
return double(_that.displayName,_that.value,_that.onChanged);case _:
  return null;

}
}

}

/// @nodoc


class ColorPropertyData<T> implements PropertyData<T> {
   ColorPropertyData({required this.displayName, required this.value, required this.onChanged});
  

@override final  String displayName;
@override final  Color value;
@override final  ValueChanged<Color> onChanged;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorPropertyDataCopyWith<T, ColorPropertyData<T>> get copyWith => _$ColorPropertyDataCopyWithImpl<T, ColorPropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorPropertyData<T>&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.value, value) || other.value == value)&&(identical(other.onChanged, onChanged) || other.onChanged == onChanged));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,value,onChanged);

@override
String toString() {
  return 'PropertyData<$T>.color(displayName: $displayName, value: $value, onChanged: $onChanged)';
}


}

/// @nodoc
abstract mixin class $ColorPropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $ColorPropertyDataCopyWith(ColorPropertyData<T> value, $Res Function(ColorPropertyData<T>) _then) = _$ColorPropertyDataCopyWithImpl;
@override @useResult
$Res call({
 String displayName, Color value, ValueChanged<Color> onChanged
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
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? value = null,Object? onChanged = null,}) {
  return _then(ColorPropertyData<T>(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as Color,onChanged: null == onChanged ? _self.onChanged : onChanged // ignore: cast_nullable_to_non_nullable
as ValueChanged<Color>,
  ));
}


}

/// @nodoc


class TogglePropertyData<T> implements PropertyData<T> {
   TogglePropertyData({required this.displayName, required this.value, required this.onChanged});
  

@override final  String displayName;
@override final  bool value;
@override final  ValueChanged<bool> onChanged;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TogglePropertyDataCopyWith<T, TogglePropertyData<T>> get copyWith => _$TogglePropertyDataCopyWithImpl<T, TogglePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TogglePropertyData<T>&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.value, value) || other.value == value)&&(identical(other.onChanged, onChanged) || other.onChanged == onChanged));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,value,onChanged);

@override
String toString() {
  return 'PropertyData<$T>.toggle(displayName: $displayName, value: $value, onChanged: $onChanged)';
}


}

/// @nodoc
abstract mixin class $TogglePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $TogglePropertyDataCopyWith(TogglePropertyData<T> value, $Res Function(TogglePropertyData<T>) _then) = _$TogglePropertyDataCopyWithImpl;
@override @useResult
$Res call({
 String displayName, bool value, ValueChanged<bool> onChanged
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
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? value = null,Object? onChanged = null,}) {
  return _then(TogglePropertyData<T>(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,onChanged: null == onChanged ? _self.onChanged : onChanged // ignore: cast_nullable_to_non_nullable
as ValueChanged<bool>,
  ));
}


}

/// @nodoc


class ChoicePropertyData<T> implements PropertyData<T> {
   ChoicePropertyData({required this.displayName, required this.value, required final  Map<Widget, T> options, required this.onChanged}): _options = options;
  

@override final  String displayName;
@override final  T value;
 final  Map<Widget, T> _options;
 Map<Widget, T> get options {
  if (_options is EqualUnmodifiableMapView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_options);
}

@override final  ValueChanged<T> onChanged;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoicePropertyDataCopyWith<T, ChoicePropertyData<T>> get copyWith => _$ChoicePropertyDataCopyWithImpl<T, ChoicePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChoicePropertyData<T>&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.value, value)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.onChanged, onChanged) || other.onChanged == onChanged));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,const DeepCollectionEquality().hash(value),const DeepCollectionEquality().hash(_options),onChanged);

@override
String toString() {
  return 'PropertyData<$T>.choice(displayName: $displayName, value: $value, options: $options, onChanged: $onChanged)';
}


}

/// @nodoc
abstract mixin class $ChoicePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $ChoicePropertyDataCopyWith(ChoicePropertyData<T> value, $Res Function(ChoicePropertyData<T>) _then) = _$ChoicePropertyDataCopyWithImpl;
@override @useResult
$Res call({
 String displayName, T value, Map<Widget, T> options, ValueChanged<T> onChanged
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
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? value = freezed,Object? options = null,Object? onChanged = null,}) {
  return _then(ChoicePropertyData<T>(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as Map<Widget, T>,onChanged: null == onChanged ? _self.onChanged : onChanged // ignore: cast_nullable_to_non_nullable
as ValueChanged<T>,
  ));
}


}

/// @nodoc


class DoublePropertyData<T> implements PropertyData<T> {
   DoublePropertyData({required this.displayName, required this.value, required this.onChanged});
  

@override final  String displayName;
@override final  double value;
@override final  ValueChanged<double> onChanged;

/// Create a copy of PropertyData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoublePropertyDataCopyWith<T, DoublePropertyData<T>> get copyWith => _$DoublePropertyDataCopyWithImpl<T, DoublePropertyData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoublePropertyData<T>&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.value, value) || other.value == value)&&(identical(other.onChanged, onChanged) || other.onChanged == onChanged));
}


@override
int get hashCode => Object.hash(runtimeType,displayName,value,onChanged);

@override
String toString() {
  return 'PropertyData<$T>.double(displayName: $displayName, value: $value, onChanged: $onChanged)';
}


}

/// @nodoc
abstract mixin class $DoublePropertyDataCopyWith<T,$Res> implements $PropertyDataCopyWith<T, $Res> {
  factory $DoublePropertyDataCopyWith(DoublePropertyData<T> value, $Res Function(DoublePropertyData<T>) _then) = _$DoublePropertyDataCopyWithImpl;
@override @useResult
$Res call({
 String displayName, double value, ValueChanged<double> onChanged
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
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? value = null,Object? onChanged = null,}) {
  return _then(DoublePropertyData<T>(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,onChanged: null == onChanged ? _self.onChanged : onChanged // ignore: cast_nullable_to_non_nullable
as ValueChanged<double>,
  ));
}


}

// dart format on
