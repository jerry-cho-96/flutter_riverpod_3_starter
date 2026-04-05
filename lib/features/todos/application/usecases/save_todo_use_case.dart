import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final saveTodoUseCaseProvider = Provider<SaveTodoUseCase>((ref) {
  return SaveTodoUseCase(ref.watch(todosRepositoryProvider));
});

class SaveTodoUseCase {
  const SaveTodoUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<Todo>> call({
    required String todoText,
    required Todo? existingTodo,
    required int? userId,
  }) async {
    final normalizedTodoText = todoText.trim();
    if (normalizedTodoText.isEmpty) {
      return const Failure<Todo>(
        AppFailure(message: '할 일 내용을 입력해 주세요.', type: FailureType.validation),
      );
    }

    try {
      if (existingTodo == null) {
        if (userId == null || userId <= 0) {
          return const Failure<Todo>(
            AppFailure(
              message: '유효한 할 일 생성 요청이 아닙니다.',
              type: FailureType.validation,
            ),
          );
        }

        final createdTodo = await _repository.addTodo(
          userId: userId,
          todo: normalizedTodoText,
        );
        return Success<Todo>(createdTodo);
      }

      final updatedTodo = await _repository.updateTodo(
        todoId: existingTodo.id,
        todo: normalizedTodoText,
        completed: existingTodo.completed,
      );
      return Success<Todo>(updatedTodo);
    } on AppException catch (error) {
      return Failure<Todo>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Todo>(
        AppFailure.fromObject(error, fallbackMessage: '할 일을 저장하지 못했습니다.'),
      );
    }
  }
}
