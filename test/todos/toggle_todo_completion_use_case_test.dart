import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/toggle_todo_completion_use_case.dart';

import 'fakes.dart';

void main() {
  group('ToggleTodoCompletionUseCase', () {
    test('성공 시 수정된 할 일을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..updateTodoResult = createTodo(id: 10, completed: true);
      final useCase = ToggleTodoCompletionUseCase(repository);

      final result = await useCase.call(todoId: 10, completed: true);

      expect(repository.updateTodoCallCount, 1);
      expect(repository.lastTodoId, 10);
      expect(repository.lastCompleted, isTrue);
      result.when(
        success: (todo) => expect(todo.completed, isTrue),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('잘못된 id면 validation 실패를 반환한다', () async {
      final useCase = ToggleTodoCompletionUseCase(FakeTodosRepository());

      final result = await useCase.call(todoId: 0, completed: true);

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 할 일 수정 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..updateTodoResult = const AppException('network error');
      final useCase = ToggleTodoCompletionUseCase(repository);

      final result = await useCase.call(todoId: 10, completed: true);

      result.when(
        success: (_) => fail('network 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.network);
          expect(error.message, 'network error');
        },
      );
    });
  });
}
