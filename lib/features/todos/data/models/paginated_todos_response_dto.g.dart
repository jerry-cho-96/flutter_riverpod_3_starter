// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_todos_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedTodosResponseDto _$PaginatedTodosResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PaginatedTodosResponseDto(
  todos: (json['todos'] as List<dynamic>)
      .map((e) => TodoDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedTodosResponseDtoToJson(
  _PaginatedTodosResponseDto instance,
) => <String, dynamic>{
  'todos': instance.todos,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
