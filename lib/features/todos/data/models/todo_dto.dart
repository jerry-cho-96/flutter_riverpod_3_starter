import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_dto.freezed.dart';
part 'todo_dto.g.dart';

@freezed
abstract class TodoDto with _$TodoDto {
  const factory TodoDto({
    required int id,
    required String todo,
    required bool completed,
    required int userId,
  }) = _TodoDto;

  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);
}
