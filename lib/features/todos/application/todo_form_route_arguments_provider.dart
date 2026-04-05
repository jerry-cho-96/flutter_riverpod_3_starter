import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/todo.dart';

part 'todo_form_route_arguments_provider.g.dart';

class TodoFormRouteArguments {
  const TodoFormRouteArguments.create()
    : isEdit = false,
      todoId = null,
      initialTodo = null;

  const TodoFormRouteArguments.edit({required this.todoId, this.initialTodo})
    : isEdit = true;

  final bool isEdit;
  final int? todoId;
  final Todo? initialTodo;
}

@riverpod
TodoFormRouteArguments todoFormRouteArguments(Ref ref) {
  throw StateError(
    '할 일 폼 화면에서 todoFormRouteArgumentsProvider 를 override 해야 합니다.',
  );
}
