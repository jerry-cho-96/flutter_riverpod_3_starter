import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  return GetTodosUseCase(ref.watch(todosRepositoryProvider));
});

class GetTodosUseCase {
  const GetTodosUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<List<Todo>>> call({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    if (userId <= 0 || limit <= 0 || skip < 0) {
      return const Failure<List<Todo>>(
        AppFailure(
          message: '유효한 할 일 목록 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final todos = await _repository.fetchTodosByUser(
        userId: userId,
        limit: limit,
        skip: skip,
      );
      return Success<List<Todo>>(todos);
    } on AppException catch (error) {
      return Failure<List<Todo>>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<List<Todo>>(
        AppFailure.fromObject(error, fallbackMessage: '할 일 목록을 불러오지 못했습니다.'),
      );
    }
  }
}
