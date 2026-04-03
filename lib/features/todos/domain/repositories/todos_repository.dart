import '../entities/todo.dart';

abstract interface class TodosRepository {
  Future<List<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  });

  Future<Todo> addTodo({required int userId, required String todo});

  Future<Todo> updateTodo({required int todoId, bool? completed});

  Future<Todo> deleteTodo({required int todoId});
}
