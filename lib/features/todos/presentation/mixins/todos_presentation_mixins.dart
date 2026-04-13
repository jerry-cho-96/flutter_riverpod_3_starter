import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/todos_controller.dart';
import '../../application/states/todos_list_state.dart';
import '../../domain/entities/todo.dart';

mixin class TodosPresentationStateMixin {
  AsyncValue<TodosListState> watchTodos(WidgetRef ref) {
    return ref.watch(todosControllerProvider);
  }
}

mixin class TodosPresentationEventMixin {
  Future<void> addTodo(WidgetRef ref, String todoText) {
    return ref.read(todosControllerProvider.notifier).addTodo(todoText);
  }

  Future<void> deleteTodo(WidgetRef ref, Todo todo) {
    return ref.read(todosControllerProvider.notifier).deleteTodo(todo);
  }

  Future<void> refreshTodos(WidgetRef ref) {
    return ref.read(todosControllerProvider.notifier).refresh();
  }

  Future<void> loadMoreTodos(WidgetRef ref) {
    return ref.read(todosControllerProvider.notifier).loadMore();
  }

  Future<void> toggleTodoCompletion(WidgetRef ref, Todo todo) {
    return ref
        .read(todosControllerProvider.notifier)
        .toggleTodoCompletion(todo);
  }
}
