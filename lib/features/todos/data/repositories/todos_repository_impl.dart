import '../../../../core/pagination/page_chunk.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/todos_remote_data_source.dart';
import '../models/todo_dto.dart';

class TodosRepositoryImpl implements TodosRepository {
  TodosRepositoryImpl(this._remoteDataSource);

  final TodosRemoteDataSource _remoteDataSource;

  @override
  Future<Todo> addTodo({required int userId, required String todo}) async {
    final dto = await _remoteDataSource.addTodo(userId: userId, todo: todo);
    return _mapTodo(dto);
  }

  @override
  Future<Todo> deleteTodo({required int todoId}) async {
    final dto = await _remoteDataSource.deleteTodo(todoId: todoId);
    return _mapTodo(dto);
  }

  @override
  Future<PageChunk<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    final response = await _remoteDataSource.fetchTodosByUser(
      userId: userId,
      limit: limit,
      skip: skip,
    );

    return PageChunk<Todo>(
      items: response.todos.map(_mapTodo).toList(growable: false),
      total: response.total,
      skip: response.skip,
      limit: response.limit,
    );
  }

  @override
  Future<Todo> updateTodo({required int todoId, bool? completed}) async {
    final dto = await _remoteDataSource.updateTodo(
      todoId: todoId,
      completed: completed,
    );
    return _mapTodo(dto);
  }

  Todo _mapTodo(TodoDto dto) {
    return Todo(
      id: dto.id,
      todo: dto.todo,
      completed: dto.completed,
      userId: dto.userId,
    );
  }
}
