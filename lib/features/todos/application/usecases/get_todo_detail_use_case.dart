import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final getTodoDetailUseCaseProvider = Provider<GetTodoDetailUseCase>((ref) {
  return GetTodoDetailUseCase(ref.watch(todosRepositoryProvider));
});

class GetTodoDetailUseCase {
  const GetTodoDetailUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<Todo>> call({required int todoId}) async {
    if (todoId <= 0) {
      return const Failure<Todo>(
        AppFailure(
          message: '유효한 할 일 상세 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final todo = await _repository.fetchTodoDetail(todoId: todoId);
      return Success<Todo>(todo);
    } on AppException catch (error) {
      return Failure<Todo>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Todo>(
        AppFailure.fromObject(error, fallbackMessage: '할 일 상세를 불러오지 못했습니다.'),
      );
    }
  }
}
