import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/get_todos_use_case.dart';
import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';

import 'fakes.dart';

void main() {
  group('GetTodosUseCase', () {
    test('성공 시 사용자 할 일 목록을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..fetchTodosResult = <Todo>[
          createTodo(id: 1, userId: 5),
          createTodo(id: 2, userId: 5),
        ];
      final useCase = GetTodosUseCase(repository);

      final result = await useCase.call(userId: 5, limit: 20, skip: 0);

      expect(repository.fetchTodosCallCount, 1);
      expect(repository.lastUserId, 5);
      result.when(
        success: (todos) => expect(todos, hasLength(2)),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('잘못된 요청이면 validation 실패를 반환한다', () async {
      final useCase = GetTodosUseCase(FakeTodosRepository());

      final result = await useCase.call(userId: 0, limit: 0, skip: -1);

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 할 일 목록 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeTodosRepository()
        ..fetchTodosResult = const AppException('network error');
      final useCase = GetTodosUseCase(repository);

      final result = await useCase.call(userId: 5, limit: 20, skip: 0);

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
