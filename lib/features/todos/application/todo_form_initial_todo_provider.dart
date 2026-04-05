import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/todo.dart';
import 'todo_form_route_arguments_provider.dart';
import 'usecases/get_todo_detail_use_case.dart';

part 'todo_form_initial_todo_provider.g.dart';

@riverpod
Future<Todo?> todoFormInitialTodo(Ref ref) async {
  final routeArguments = ref.watch(todoFormRouteArgumentsProvider);
  if (!routeArguments.isEdit) {
    return null;
  }

  final initialTodo = routeArguments.initialTodo;
  if (initialTodo != null) {
    return initialTodo;
  }

  final todoId = routeArguments.todoId;
  if (todoId == null) {
    throw StateError('edit 모드에서는 todoId가 필요합니다.');
  }

  final result = await ref
      .read(getTodoDetailUseCaseProvider)
      .call(todoId: todoId);
  return result.when(success: (todo) => todo, failure: (error) => throw error);
}
