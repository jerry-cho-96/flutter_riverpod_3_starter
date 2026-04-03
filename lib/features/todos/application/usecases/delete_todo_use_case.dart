import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  return DeleteTodoUseCase(ref.watch(todosRepositoryProvider));
});

class DeleteTodoUseCase {
  const DeleteTodoUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<Todo>> call({required int todoId}) async {
    if (todoId <= 0) {
      return const Failure<Todo>(
        AppFailure(
          message: '유효한 할 일 삭제 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final deletedTodo = await _repository.deleteTodo(todoId: todoId);
      return Success<Todo>(deletedTodo);
    } on AppException catch (error) {
      return Failure<Todo>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Todo>(
        AppFailure.fromObject(error, fallbackMessage: '할 일을 삭제하지 못했습니다.'),
      );
    }
  }
}
