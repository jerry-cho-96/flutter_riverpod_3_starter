import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';
import 'package:riverpod_origin_template/features/todos/domain/repositories/todos_repository.dart';

Todo createTodo({
  int id = 1,
  String todo = 'AGENTS 문서 확인하기',
  bool completed = false,
  int userId = 1,
}) {
  return Todo(id: id, todo: todo, completed: completed, userId: userId);
}

class FakeTodosRepository implements TodosRepository {
  Object? fetchTodosResult;
  Object? addTodoResult;
  Object? updateTodoResult;
  Object? deleteTodoResult;
  int fetchTodosCallCount = 0;
  int addTodoCallCount = 0;
  int updateTodoCallCount = 0;
  int deleteTodoCallCount = 0;
  int? lastUserId;
  int? lastLimit;
  int? lastSkip;
  int? lastTodoId;
  String? lastTodoText;
  bool? lastCompleted;

  @override
  Future<Todo> addTodo({required int userId, required String todo}) async {
    addTodoCallCount += 1;
    lastUserId = userId;
    lastTodoText = todo;
    return _resolve<Todo>(
      addTodoResult,
      fallback: createTodo(id: 151, todo: todo, userId: userId),
    );
  }

  @override
  Future<Todo> deleteTodo({required int todoId}) async {
    deleteTodoCallCount += 1;
    lastTodoId = todoId;
    return _resolve<Todo>(deleteTodoResult, fallback: createTodo(id: todoId));
  }

  @override
  Future<List<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    fetchTodosCallCount += 1;
    lastUserId = userId;
    lastLimit = limit;
    lastSkip = skip;
    return _resolve<List<Todo>>(
      fetchTodosResult,
      fallback: <Todo>[createTodo(userId: userId)],
    );
  }

  @override
  Future<Todo> updateTodo({required int todoId, bool? completed}) async {
    updateTodoCallCount += 1;
    lastTodoId = todoId;
    lastCompleted = completed;
    return _resolve<Todo>(
      updateTodoResult,
      fallback: createTodo(id: todoId, completed: completed ?? false),
    );
  }

  Future<T> _resolve<T>(Object? value, {required Object fallback}) async {
    final result = value ?? fallback;
    if (result is Future<T>) {
      return await result;
    }
    if (result is Future) {
      return (await result) as T;
    }
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as T;
  }
}
