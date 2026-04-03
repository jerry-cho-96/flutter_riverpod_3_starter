import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/delete_todo_use_case.dart';

import 'fakes.dart';

void main() {
  group('DeleteTodoUseCase', () {
    test('성공 시 삭제된 할 일을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..deleteTodoResult = createTodo(id: 10);
      final useCase = DeleteTodoUseCase(repository);

      final result = await useCase.call(todoId: 10);

      expect(repository.deleteTodoCallCount, 1);
      expect(repository.lastTodoId, 10);
      result.when(
        success: (todo) => expect(todo.id, 10),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('잘못된 id면 validation 실패를 반환한다', () async {
      final useCase = DeleteTodoUseCase(FakeTodosRepository());

      final result = await useCase.call(todoId: 0);

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 할 일 삭제 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..deleteTodoResult = const AppException('network error');
      final useCase = DeleteTodoUseCase(repository);

      final result = await useCase.call(todoId: 10);

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
