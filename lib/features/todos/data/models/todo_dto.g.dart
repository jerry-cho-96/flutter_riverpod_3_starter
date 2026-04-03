// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoDto _$TodoDtoFromJson(Map<String, dynamic> json) => _TodoDto(
  id: (json['id'] as num).toInt(),
  todo: json['todo'] as String,
  completed: json['completed'] as bool,
  userId: (json['userId'] as num).toInt(),
);

Map<String, dynamic> _$TodoDtoToJson(_TodoDto instance) => <String, dynamic>{
  'id': instance.id,
  'todo': instance.todo,
  'completed': instance.completed,
  'userId': instance.userId,
};
