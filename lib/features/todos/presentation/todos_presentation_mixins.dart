import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/todos_controller.dart';
import '../domain/entities/todo.dart';

mixin class TodosPresentationStateMixin {
  AsyncValue<List<Todo>> watchTodos(WidgetRef ref) {
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

  Future<void> toggleTodoCompletion(WidgetRef ref, Todo todo) {
    return ref
        .read(todosControllerProvider.notifier)
        .toggleTodoCompletion(todo);
  }
}
