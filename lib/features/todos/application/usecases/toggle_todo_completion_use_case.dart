import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final toggleTodoCompletionUseCaseProvider =
    Provider<ToggleTodoCompletionUseCase>((ref) {
      return ToggleTodoCompletionUseCase(ref.watch(todosRepositoryProvider));
    });

class ToggleTodoCompletionUseCase {
  const ToggleTodoCompletionUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<Todo>> call({
    required int todoId,
    required bool completed,
  }) async {
    if (todoId <= 0) {
      return const Failure<Todo>(
        AppFailure(
          message: '유효한 할 일 수정 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final updatedTodo = await _repository.updateTodo(
        todoId: todoId,
        todo: null,
        completed: completed,
      );
      return Success<Todo>(updatedTodo);
    } on AppException catch (error) {
      return Failure<Todo>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Todo>(
        AppFailure.fromObject(error, fallbackMessage: '할 일 상태를 변경하지 못했습니다.'),
      );
    }
  }
}
