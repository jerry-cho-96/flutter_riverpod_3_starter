import 'package:freezed_annotation/freezed_annotation.dart';

import 'todo_dto.dart';

part 'paginated_todos_response_dto.freezed.dart';
part 'paginated_todos_response_dto.g.dart';

@freezed
abstract class PaginatedTodosResponseDto with _$PaginatedTodosResponseDto {
  const factory PaginatedTodosResponseDto({
    required List<TodoDto> todos,
    required int total,
    required int skip,
    required int limit,
  }) = _PaginatedTodosResponseDto;

  factory PaginatedTodosResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaginatedTodosResponseDtoFromJson(json);
}
