import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/app_exception.dart';
import '../models/paginated_todos_response_dto.dart';
import '../models/todo_dto.dart';

final todosRemoteDataSourceProvider = Provider<TodosRemoteDataSource>((ref) {
  return TodosRemoteDataSource(dio: ref.watch(dioProvider));
});

class TodosRemoteDataSource {
  TodosRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PaginatedTodosResponseDto> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/todos/user/$userId',
        queryParameters: <String, Object>{'limit': limit, 'skip': skip},
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('할 일 목록 응답이 비어 있습니다.');
      }

      return PaginatedTodosResponseDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<TodoDto> fetchTodoDetail({required int todoId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/todos/$todoId');
      final json = response.data;
      if (json == null) {
        throw const AppException('할 일 상세 응답이 비어 있습니다.');
      }

      return TodoDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<TodoDto> addTodo({required int userId, required String todo}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/todos/add',
        data: <String, Object>{
          'todo': todo,
          'completed': false,
          'userId': userId,
        },
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('할 일 생성 응답이 비어 있습니다.');
      }

      return TodoDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<TodoDto> updateTodo({
    required int todoId,
    String? todo,
    bool? completed,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/todos/$todoId',
        data: <String, Object?>{'todo': todo, 'completed': completed},
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('할 일 수정 응답이 비어 있습니다.');
      }

      return TodoDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<TodoDto> deleteTodo({required int todoId}) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/todos/$todoId',
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('할 일 삭제 응답이 비어 있습니다.');
      }

      return TodoDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }
}
