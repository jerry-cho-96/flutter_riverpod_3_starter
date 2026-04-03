import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final addTodoUseCaseProvider = Provider<AddTodoUseCase>((ref) {
  return AddTodoUseCase(ref.watch(todosRepositoryProvider));
});

class AddTodoUseCase {
  const AddTodoUseCase(this._repository);

  final TodosRepository _repository;

  Future<Result<Todo>> call({required int userId, required String todo}) async {
    if (userId <= 0 || todo.trim().isEmpty) {
      return const Failure<Todo>(
        AppFailure(
          message: '유효한 할 일 생성 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final createdTodo = await _repository.addTodo(
        userId: userId,
        todo: todo.trim(),
      );
      return Success<Todo>(createdTodo);
    } on AppException catch (error) {
      return Failure<Todo>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Todo>(
        AppFailure.fromObject(error, fallbackMessage: '할 일을 추가하지 못했습니다.'),
      );
    }
  }
}
