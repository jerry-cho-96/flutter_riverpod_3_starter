import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/todo.dart';
import 'current_todo_user_id_provider.dart';
import 'usecases/add_todo_use_case.dart';
import 'usecases/delete_todo_use_case.dart';
import 'usecases/get_todos_use_case.dart';
import 'usecases/toggle_todo_completion_use_case.dart';

part 'todos_controller.g.dart';

@riverpod
class TodosController extends _$TodosController {
  final Set<int> _dirtyTodoIds = <int>{};
  final Set<int> _deletedTodoIds = <int>{};
  final Set<int> _localOnlyTodoIds = <int>{};

  @override
  Future<List<Todo>> build() {
    return _load();
  }

  Future<void> addTodo(String todoText) async {
    final userId = ref.read(currentTodoUserIdProvider);
    final createdTodo = await _unwrap<Todo>(
      ref.read(addTodoUseCaseProvider).call(userId: userId, todo: todoText),
    );
    _dirtyTodoIds.add(createdTodo.id);
    _deletedTodoIds.remove(createdTodo.id);
    _localOnlyTodoIds.add(createdTodo.id);
    final currentTodos = state.value ?? const <Todo>[];
    state = AsyncData(<Todo>[createdTodo, ...currentTodos]);
  }

  Future<void> deleteTodo(Todo todo) async {
    if (_localOnlyTodoIds.remove(todo.id)) {
      _dirtyTodoIds.remove(todo.id);
      _deletedTodoIds.remove(todo.id);
      final currentTodos = state.value ?? const <Todo>[];
      state = AsyncData(
        currentTodos
            .where((item) => item.id != todo.id)
            .toList(growable: false),
      );
      return;
    }

    final deletedTodo = await _unwrap<Todo>(
      ref.read(deleteTodoUseCaseProvider).call(todoId: todo.id),
    );
    _deletedTodoIds.add(deletedTodo.id);
    _dirtyTodoIds.remove(deletedTodo.id);
    final currentTodos = state.value ?? const <Todo>[];
    state = AsyncData(
      currentTodos
          .where((item) => item.id != deletedTodo.id)
          .toList(growable: false),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    if (_localOnlyTodoIds.contains(todo.id)) {
      _dirtyTodoIds.add(todo.id);
      final currentTodos = state.value ?? const <Todo>[];
      state = AsyncData(
        currentTodos
            .map(
              (item) => item.id == todo.id
                  ? item.copyWith(completed: !item.completed)
                  : item,
            )
            .toList(growable: false),
      );
      return;
    }

    final updatedTodo = await _unwrap<Todo>(
      ref
          .read(toggleTodoCompletionUseCaseProvider)
          .call(todoId: todo.id, completed: !todo.completed),
    );
    _dirtyTodoIds.add(updatedTodo.id);
    final currentTodos = state.value ?? const <Todo>[];
    state = AsyncData(
      currentTodos
          .map((item) => item.id == updatedTodo.id ? updatedTodo : item)
          .toList(growable: false),
    );
  }

  Future<List<Todo>> _load() async {
    final userId = ref.read(currentTodoUserIdProvider);
    final fetchedTodos = await _unwrap<List<Todo>>(
      ref
          .read(getTodosUseCaseProvider)
          .call(userId: userId, limit: 20, skip: 0),
    );

    if (!ref.mounted) {
      return fetchedTodos;
    }

    return _mergeFetchedTodos(fetchedTodos);
  }

  Future<T> _unwrap<T>(Future<dynamic> resultFuture) async {
    final result = await resultFuture;
    return result.when(
      success: (value) => value as T,
      failure: (error) => throw error,
    );
  }

  List<Todo> _mergeFetchedTodos(List<Todo> fetchedTodos) {
    final currentTodos = state.value ?? const <Todo>[];
    final currentById = <int, Todo>{
      for (final todo in currentTodos) todo.id: todo,
    };
    final fetchedById = <int, Todo>{
      for (final todo in fetchedTodos) todo.id: todo,
    };
    final mergedTodos = <Todo>[
      for (final todo in currentTodos)
        if (!_deletedTodoIds.contains(todo.id) &&
            !fetchedById.containsKey(todo.id) &&
            _dirtyTodoIds.contains(todo.id))
          todo,
      for (final todo in fetchedTodos)
        if (!_deletedTodoIds.contains(todo.id))
          _dirtyTodoIds.contains(todo.id) && currentById.containsKey(todo.id)
              ? currentById[todo.id]!
              : todo,
    ];

    _dirtyTodoIds.removeWhere((todoId) {
      final currentTodo = currentById[todoId];
      final fetchedTodo = fetchedById[todoId];
      return currentTodo != null &&
          fetchedTodo != null &&
          currentTodo == fetchedTodo;
    });
    _deletedTodoIds.removeWhere((todoId) => !fetchedById.containsKey(todoId));
    _localOnlyTodoIds.removeWhere((todoId) => fetchedById.containsKey(todoId));

    return mergedTodos;
  }
}
