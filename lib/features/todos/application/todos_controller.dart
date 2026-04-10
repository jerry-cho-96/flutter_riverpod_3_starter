import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/pagination/page_chunk.dart';
import '../domain/entities/todo.dart';
import 'current_todo_user_id_provider.dart';
import 'todos_list_state.dart';
import 'usecases/add_todo_use_case.dart';
import 'usecases/delete_todo_use_case.dart';
import 'usecases/get_todos_use_case.dart';
import 'usecases/toggle_todo_completion_use_case.dart';

part 'todos_controller.g.dart';

@riverpod
class TodosController extends _$TodosController {
  static const int _pageSize = 20;

  final Set<int> _dirtyTodoIds = <int>{};
  final Set<int> _deletedTodoIds = <int>{};
  final Set<int> _localOnlyTodoIds = <int>{};

  @override
  Future<TodosListState> build() {
    return _load();
  }

  Future<void> addTodo(String todoText) async {
    final userId = ref.read(currentTodoUserIdProvider);
    final createdTodo = await _unwrap<Todo>(
      ref.read(addTodoUseCaseProvider).call(userId: userId, todo: todoText),
    );
    _clearTodosQueryCache();
    _dirtyTodoIds.add(createdTodo.id);
    _deletedTodoIds.remove(createdTodo.id);
    _localOnlyTodoIds.add(createdTodo.id);
    final currentState =
        state.value ?? TodosListState.empty(pageSize: _pageSize);
    state = AsyncData(
      currentState.copyWith(
        items: <Todo>[createdTodo, ...currentState.items],
        localOnlyCount: _localOnlyTodoIds.length,
      ),
    );
  }

  Future<void> deleteTodo(Todo todo) async {
    final currentState =
        state.value ?? TodosListState.empty(pageSize: _pageSize);
    if (_localOnlyTodoIds.remove(todo.id)) {
      _clearTodosQueryCache();
      _dirtyTodoIds.remove(todo.id);
      _deletedTodoIds.remove(todo.id);
      state = AsyncData(
        currentState.copyWith(
          items: currentState.items
              .where((item) => item.id != todo.id)
              .toList(growable: false),
          localOnlyCount: _localOnlyTodoIds.length,
        ),
      );
      return;
    }

    final deletedTodo = await _unwrap<Todo>(
      ref.read(deleteTodoUseCaseProvider).call(todoId: todo.id),
    );
    _clearTodosQueryCache();
    _deletedTodoIds.add(deletedTodo.id);
    _dirtyTodoIds.remove(deletedTodo.id);
    state = AsyncData(
      currentState.copyWith(
        items: currentState.items
            .where((item) => item.id != deletedTodo.id)
            .toList(growable: false),
        remoteTotalCount: currentState.remoteTotalCount > 0
            ? currentState.remoteTotalCount - 1
            : 0,
        loadedRemoteCount: currentState.loadedRemoteCount > 0
            ? currentState.loadedRemoteCount - 1
            : 0,
      ),
    );
  }

  Future<void> refresh() async {
    _clearTodosQueryCache();
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        state.isLoading ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    final userId = ref.read(currentTodoUserIdProvider);
    state = AsyncData(currentState.beginLoadMore());

    final result = await ref
        .read(getTodosUseCaseProvider)
        .call(
          userId: userId,
          limit: _pageSize,
          skip: currentState.nextRemoteSkip,
        );

    if (!ref.mounted) {
      return;
    }

    result.when(
      success: (page) {
        final nextItems = _mergeLoadMoreTodos(
          currentState: currentState,
          fetchedTodos: page.items,
        );
        state = AsyncData(
          currentState.appendRemotePage(
            nextItems,
            fetchedCount: page.items.length,
            remoteTotalCount: page.total,
            localOnlyCount: _localOnlyTodoIds.length,
          ),
        );
      },
      failure: (failure) {
        state = AsyncData(currentState.failLoadMore(failure));
      },
    );
  }

  Future<void> toggleTodoCompletion(Todo todo) async {
    final currentState =
        state.value ?? TodosListState.empty(pageSize: _pageSize);
    if (_localOnlyTodoIds.contains(todo.id)) {
      _clearTodosQueryCache();
      _dirtyTodoIds.add(todo.id);
      state = AsyncData(
        currentState.copyWith(
          items: currentState.items
              .map(
                (item) => item.id == todo.id
                    ? item.copyWith(completed: !item.completed)
                    : item,
              )
              .toList(growable: false),
        ),
      );
      return;
    }

    final updatedTodo = await _unwrap<Todo>(
      ref
          .read(toggleTodoCompletionUseCaseProvider)
          .call(todoId: todo.id, completed: !todo.completed),
    );
    _clearTodosQueryCache();
    _dirtyTodoIds.add(updatedTodo.id);
    state = AsyncData(
      currentState.copyWith(
        items: currentState.items
            .map((item) => item.id == updatedTodo.id ? updatedTodo : item)
            .toList(growable: false),
      ),
    );
  }

  Future<TodosListState> _load() async {
    final userId = ref.read(currentTodoUserIdProvider);
    final page = await _unwrap<PageChunk<Todo>>(
      ref
          .read(getTodosUseCaseProvider)
          .call(userId: userId, limit: _pageSize, skip: 0),
    );
    final fetchedTodos = page.items;

    if (!ref.mounted) {
      return TodosListState(
        items: fetchedTodos,
        pageSize: _pageSize,
        remoteTotalCount: page.total,
        loadedRemoteCount: fetchedTodos.length,
        localOnlyCount: _localOnlyTodoIds.length,
      );
    }

    final currentState =
        state.value ?? TodosListState.empty(pageSize: _pageSize);
    final mergedTodos = _mergeFetchedTodos(
      currentState: currentState,
      fetchedTodos: fetchedTodos,
    );

    return TodosListState(
      items: mergedTodos,
      pageSize: _pageSize,
      remoteTotalCount: page.total,
      loadedRemoteCount: fetchedTodos.length,
      localOnlyCount: _localOnlyTodoIds.length,
    );
  }

  Future<T> _unwrap<T>(Future<dynamic> resultFuture) async {
    final result = await resultFuture;
    return result.when(
      success: (value) => value as T,
      failure: (error) => throw error,
    );
  }

  List<Todo> _mergeFetchedTodos({
    required TodosListState currentState,
    required List<Todo> fetchedTodos,
  }) {
    final currentTodos = currentState.items;
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

  List<Todo> _mergeLoadMoreTodos({
    required TodosListState currentState,
    required List<Todo> fetchedTodos,
  }) {
    final currentById = <int, Todo>{
      for (final todo in currentState.items) todo.id: todo,
    };
    final nextItems = <Todo>[];

    for (final todo in fetchedTodos) {
      if (_deletedTodoIds.contains(todo.id)) {
        continue;
      }

      final currentTodo = currentById[todo.id];
      if (currentTodo == null) {
        nextItems.add(todo);
        continue;
      }

      if (_dirtyTodoIds.contains(todo.id) && currentTodo == todo) {
        _dirtyTodoIds.remove(todo.id);
      }
    }

    return nextItems;
  }

  void _clearTodosQueryCache() {
    ref.read(getTodosUseCaseProvider).clearCache();
  }
}
