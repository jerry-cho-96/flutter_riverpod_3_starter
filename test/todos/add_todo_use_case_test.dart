import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/add_todo_use_case.dart';

import 'fakes.dart';

void main() {
  group('AddTodoUseCase', () {
    test('성공 시 생성된 할 일을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..addTodoResult = createTodo(id: 151, todo: '문서 갱신하기', userId: 5);
      final useCase = AddTodoUseCase(repository);

      final result = await useCase.call(userId: 5, todo: '문서 갱신하기');

      expect(repository.addTodoCallCount, 1);
      expect(repository.lastTodoText, '문서 갱신하기');
      result.when(
        success: (todo) => expect(todo.id, 151),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('빈 요청이면 validation 실패를 반환한다', () async {
      final useCase = AddTodoUseCase(FakeTodosRepository());

      final result = await useCase.call(userId: 5, todo: '   ');

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 할 일 생성 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..addTodoResult = const AppException('network error');
      final useCase = AddTodoUseCase(repository);

      final result = await useCase.call(userId: 5, todo: '테스트 작성하기');

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
