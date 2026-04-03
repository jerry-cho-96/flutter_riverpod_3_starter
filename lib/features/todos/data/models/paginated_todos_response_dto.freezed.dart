// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_todos_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedTodosResponseDto {

 List<TodoDto> get todos; int get total; int get skip; int get limit;
/// Create a copy of PaginatedTodosResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedTodosResponseDtoCopyWith<PaginatedTodosResponseDto> get copyWith => _$PaginatedTodosResponseDtoCopyWithImpl<PaginatedTodosResponseDto>(this as PaginatedTodosResponseDto, _$identity);

  /// Serializes this PaginatedTodosResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedTodosResponseDto&&const DeepCollectionEquality().equals(other.todos, todos)&&(identical(other.total, total) || other.total == total)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(todos),total,skip,limit);

@override
String toString() {
  return 'PaginatedTodosResponseDto(todos: $todos, total: $total, skip: $skip, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $PaginatedTodosResponseDtoCopyWith<$Res>  {
  factory $PaginatedTodosResponseDtoCopyWith(PaginatedTodosResponseDto value, $Res Function(PaginatedTodosResponseDto) _then) = _$PaginatedTodosResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<TodoDto> todos, int total, int skip, int limit
});




}
/// @nodoc
class _$PaginatedTodosResponseDtoCopyWithImpl<$Res>
    implements $PaginatedTodosResponseDtoCopyWith<$Res> {
  _$PaginatedTodosResponseDtoCopyWithImpl(this._self, this._then);

  final PaginatedTodosResponseDto _self;
  final $Res Function(PaginatedTodosResponseDto) _then;

/// Create a copy of PaginatedTodosResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todos = null,Object? total = null,Object? skip = null,Object? limit = null,}) {
  return _then(_self.copyWith(
todos: null == todos ? _self.todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedTodosResponseDto].
extension PaginatedTodosResponseDtoPatterns on PaginatedTodosResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedTodosResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedTodosResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedTodosResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TodoDto> todos,  int total,  int skip,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto() when $default != null:
return $default(_that.todos,_that.total,_that.skip,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TodoDto> todos,  int total,  int skip,  int limit)  $default,) {final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto():
return $default(_that.todos,_that.total,_that.skip,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TodoDto> todos,  int total,  int skip,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedTodosResponseDto() when $default != null:
return $default(_that.todos,_that.total,_that.skip,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedTodosResponseDto implements PaginatedTodosResponseDto {
  const _PaginatedTodosResponseDto({required final  List<TodoDto> todos, required this.total, required this.skip, required this.limit}): _todos = todos;
  factory _PaginatedTodosResponseDto.fromJson(Map<String, dynamic> json) => _$PaginatedTodosResponseDtoFromJson(json);

 final  List<TodoDto> _todos;
@override List<TodoDto> get todos {
  if (_todos is EqualUnmodifiableListView) return _todos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_todos);
}

@override final  int total;
@override final  int skip;
@override final  int limit;

/// Create a copy of PaginatedTodosResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedTodosResponseDtoCopyWith<_PaginatedTodosResponseDto> get copyWith => __$PaginatedTodosResponseDtoCopyWithImpl<_PaginatedTodosResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedTodosResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedTodosResponseDto&&const DeepCollectionEquality().equals(other._todos, _todos)&&(identical(other.total, total) || other.total == total)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_todos),total,skip,limit);

@override
String toString() {
  return 'PaginatedTodosResponseDto(todos: $todos, total: $total, skip: $skip, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$PaginatedTodosResponseDtoCopyWith<$Res> implements $PaginatedTodosResponseDtoCopyWith<$Res> {
  factory _$PaginatedTodosResponseDtoCopyWith(_PaginatedTodosResponseDto value, $Res Function(_PaginatedTodosResponseDto) _then) = __$PaginatedTodosResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<TodoDto> todos, int total, int skip, int limit
});




}
/// @nodoc
class __$PaginatedTodosResponseDtoCopyWithImpl<$Res>
    implements _$PaginatedTodosResponseDtoCopyWith<$Res> {
  __$PaginatedTodosResponseDtoCopyWithImpl(this._self, this._then);

  final _PaginatedTodosResponseDto _self;
  final $Res Function(_PaginatedTodosResponseDto) _then;

/// Create a copy of PaginatedTodosResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todos = null,Object? total = null,Object? skip = null,Object? limit = null,}) {
  return _then(_PaginatedTodosResponseDto(
todos: null == todos ? _self._todos : todos // ignore: cast_nullable_to_non_nullable
as List<TodoDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
