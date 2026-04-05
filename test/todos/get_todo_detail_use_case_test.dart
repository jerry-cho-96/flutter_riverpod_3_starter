import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/get_todo_detail_use_case.dart';

import 'fakes.dart';

void main() {
  group('GetTodoDetailUseCase', () {
    test('성공 시 할 일 상세를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..fetchTodoDetailResult = createTodo(id: 7, todo: '기존 작업', userId: 5);
      final useCase = GetTodoDetailUseCase(repository);

      final result = await useCase.call(todoId: 7);

      expect(repository.fetchTodoDetailCallCount, 1);
      expect(repository.lastTodoId, 7);
      result.when(
        success: (todo) => expect(todo.todo, '기존 작업'),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('유효하지 않은 id 면 validation 실패를 반환한다', () async {
      final useCase = GetTodoDetailUseCase(FakeTodosRepository());

      final result = await useCase.call(todoId: 0);

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 할 일 상세 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..fetchTodoDetailResult = const AppException('network error');
      final useCase = GetTodoDetailUseCase(repository);

      final result = await useCase.call(todoId: 7);

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
