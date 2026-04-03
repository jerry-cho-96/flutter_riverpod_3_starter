// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_quotes_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedQuotesResponseDto {

 List<QuoteDto> get quotes; int get total; int get skip; int get limit;
/// Create a copy of PaginatedQuotesResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedQuotesResponseDtoCopyWith<PaginatedQuotesResponseDto> get copyWith => _$PaginatedQuotesResponseDtoCopyWithImpl<PaginatedQuotesResponseDto>(this as PaginatedQuotesResponseDto, _$identity);

  /// Serializes this PaginatedQuotesResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedQuotesResponseDto&&const DeepCollectionEquality().equals(other.quotes, quotes)&&(identical(other.total, total) || other.total == total)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(quotes),total,skip,limit);

@override
String toString() {
  return 'PaginatedQuotesResponseDto(quotes: $quotes, total: $total, skip: $skip, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $PaginatedQuotesResponseDtoCopyWith<$Res>  {
  factory $PaginatedQuotesResponseDtoCopyWith(PaginatedQuotesResponseDto value, $Res Function(PaginatedQuotesResponseDto) _then) = _$PaginatedQuotesResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<QuoteDto> quotes, int total, int skip, int limit
});




}
/// @nodoc
class _$PaginatedQuotesResponseDtoCopyWithImpl<$Res>
    implements $PaginatedQuotesResponseDtoCopyWith<$Res> {
  _$PaginatedQuotesResponseDtoCopyWithImpl(this._self, this._then);

  final PaginatedQuotesResponseDto _self;
  final $Res Function(PaginatedQuotesResponseDto) _then;

/// Create a copy of PaginatedQuotesResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? quotes = null,Object? total = null,Object? skip = null,Object? limit = null,}) {
  return _then(_self.copyWith(
quotes: null == quotes ? _self.quotes : quotes // ignore: cast_nullable_to_non_nullable
as List<QuoteDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedQuotesResponseDto].
extension PaginatedQuotesResponseDtoPatterns on PaginatedQuotesResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedQuotesResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedQuotesResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedQuotesResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<QuoteDto> quotes,  int total,  int skip,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto() when $default != null:
return $default(_that.quotes,_that.total,_that.skip,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<QuoteDto> quotes,  int total,  int skip,  int limit)  $default,) {final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto():
return $default(_that.quotes,_that.total,_that.skip,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<QuoteDto> quotes,  int total,  int skip,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedQuotesResponseDto() when $default != null:
return $default(_that.quotes,_that.total,_that.skip,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedQuotesResponseDto implements PaginatedQuotesResponseDto {
  const _PaginatedQuotesResponseDto({required final  List<QuoteDto> quotes, required this.total, required this.skip, required this.limit}): _quotes = quotes;
  factory _PaginatedQuotesResponseDto.fromJson(Map<String, dynamic> json) => _$PaginatedQuotesResponseDtoFromJson(json);

 final  List<QuoteDto> _quotes;
@override List<QuoteDto> get quotes {
  if (_quotes is EqualUnmodifiableListView) return _quotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quotes);
}

@override final  int total;
@override final  int skip;
@override final  int limit;

/// Create a copy of PaginatedQuotesResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedQuotesResponseDtoCopyWith<_PaginatedQuotesResponseDto> get copyWith => __$PaginatedQuotesResponseDtoCopyWithImpl<_PaginatedQuotesResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedQuotesResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedQuotesResponseDto&&const DeepCollectionEquality().equals(other._quotes, _quotes)&&(identical(other.total, total) || other.total == total)&&(identical(other.skip, skip) || other.skip == skip)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_quotes),total,skip,limit);

@override
String toString() {
  return 'PaginatedQuotesResponseDto(quotes: $quotes, total: $total, skip: $skip, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$PaginatedQuotesResponseDtoCopyWith<$Res> implements $PaginatedQuotesResponseDtoCopyWith<$Res> {
  factory _$PaginatedQuotesResponseDtoCopyWith(_PaginatedQuotesResponseDto value, $Res Function(_PaginatedQuotesResponseDto) _then) = __$PaginatedQuotesResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<QuoteDto> quotes, int total, int skip, int limit
});




}
/// @nodoc
class __$PaginatedQuotesResponseDtoCopyWithImpl<$Res>
    implements _$PaginatedQuotesResponseDtoCopyWith<$Res> {
  __$PaginatedQuotesResponseDtoCopyWithImpl(this._self, this._then);

  final _PaginatedQuotesResponseDto _self;
  final $Res Function(_PaginatedQuotesResponseDto) _then;

/// Create a copy of PaginatedQuotesResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? quotes = null,Object? total = null,Object? skip = null,Object? limit = null,}) {
  return _then(_PaginatedQuotesResponseDto(
quotes: null == quotes ? _self._quotes : quotes // ignore: cast_nullable_to_non_nullable
as List<QuoteDto>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,skip: null == skip ? _self.skip : skip // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
