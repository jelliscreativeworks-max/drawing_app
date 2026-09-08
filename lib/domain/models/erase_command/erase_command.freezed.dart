// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'erase_command.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EraseCommand {

 String get layerId; String get toolName; Map<int, CanvasCommand> get erasedCommands;
/// Create a copy of EraseCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EraseCommandCopyWith<EraseCommand> get copyWith => _$EraseCommandCopyWithImpl<EraseCommand>(this as EraseCommand, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EraseCommand&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other.erasedCommands, erasedCommands));
}


@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,const DeepCollectionEquality().hash(erasedCommands));

@override
String toString() {
  return 'EraseCommand(layerId: $layerId, toolName: $toolName, erasedCommands: $erasedCommands)';
}


}

/// @nodoc
abstract mixin class $EraseCommandCopyWith<$Res>  {
  factory $EraseCommandCopyWith(EraseCommand value, $Res Function(EraseCommand) _then) = _$EraseCommandCopyWithImpl;
@useResult
$Res call({
 String layerId, String toolName, Map<int, CanvasCommand> erasedCommands
});




}
/// @nodoc
class _$EraseCommandCopyWithImpl<$Res>
    implements $EraseCommandCopyWith<$Res> {
  _$EraseCommandCopyWithImpl(this._self, this._then);

  final EraseCommand _self;
  final $Res Function(EraseCommand) _then;

/// Create a copy of EraseCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? layerId = null,Object? toolName = null,Object? erasedCommands = null,}) {
  return _then(_self.copyWith(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,erasedCommands: null == erasedCommands ? _self.erasedCommands : erasedCommands // ignore: cast_nullable_to_non_nullable
as Map<int, CanvasCommand>,
  ));
}

}


/// Adds pattern-matching-related methods to [EraseCommand].
extension EraseCommandPatterns on EraseCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EraseCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EraseCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EraseCommand value)  $default,){
final _that = this;
switch (_that) {
case _EraseCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EraseCommand value)?  $default,){
final _that = this;
switch (_that) {
case _EraseCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String layerId,  String toolName,  Map<int, CanvasCommand> erasedCommands)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EraseCommand() when $default != null:
return $default(_that.layerId,_that.toolName,_that.erasedCommands);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String layerId,  String toolName,  Map<int, CanvasCommand> erasedCommands)  $default,) {final _that = this;
switch (_that) {
case _EraseCommand():
return $default(_that.layerId,_that.toolName,_that.erasedCommands);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String layerId,  String toolName,  Map<int, CanvasCommand> erasedCommands)?  $default,) {final _that = this;
switch (_that) {
case _EraseCommand() when $default != null:
return $default(_that.layerId,_that.toolName,_that.erasedCommands);case _:
  return null;

}
}

}

/// @nodoc


class _EraseCommand extends EraseCommand {
  const _EraseCommand({required final  String layerId, required final  String toolName, required final  Map<int, CanvasCommand> erasedCommands}): _erasedCommands = erasedCommands,super._(layerId: layerId, toolName: toolName);
  

 final  Map<int, CanvasCommand> _erasedCommands;
@override Map<int, CanvasCommand> get erasedCommands {
  if (_erasedCommands is EqualUnmodifiableMapView) return _erasedCommands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_erasedCommands);
}


/// Create a copy of EraseCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EraseCommandCopyWith<_EraseCommand> get copyWith => __$EraseCommandCopyWithImpl<_EraseCommand>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EraseCommand&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._erasedCommands, _erasedCommands));
}


@override
int get hashCode => Object.hash(runtimeType,layerId,toolName,const DeepCollectionEquality().hash(_erasedCommands));

@override
String toString() {
  return 'EraseCommand(layerId: $layerId, toolName: $toolName, erasedCommands: $erasedCommands)';
}


}

/// @nodoc
abstract mixin class _$EraseCommandCopyWith<$Res> implements $EraseCommandCopyWith<$Res> {
  factory _$EraseCommandCopyWith(_EraseCommand value, $Res Function(_EraseCommand) _then) = __$EraseCommandCopyWithImpl;
@override @useResult
$Res call({
 String layerId, String toolName, Map<int, CanvasCommand> erasedCommands
});




}
/// @nodoc
class __$EraseCommandCopyWithImpl<$Res>
    implements _$EraseCommandCopyWith<$Res> {
  __$EraseCommandCopyWithImpl(this._self, this._then);

  final _EraseCommand _self;
  final $Res Function(_EraseCommand) _then;

/// Create a copy of EraseCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? layerId = null,Object? toolName = null,Object? erasedCommands = null,}) {
  return _then(_EraseCommand(
layerId: null == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,erasedCommands: null == erasedCommands ? _self._erasedCommands : erasedCommands // ignore: cast_nullable_to_non_nullable
as Map<int, CanvasCommand>,
  ));
}


}

// dart format on
