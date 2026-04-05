import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/save_todo_use_case.dart';

import 'fakes.dart';

void main() {
  group('SaveTodoUseCase', () {
    test('create 성공 시 생성된 할 일을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..addTodoResult = createTodo(id: 10, todo: '문서 정리하기', userId: 5);
      final useCase = SaveTodoUseCase(repository);

      final result = await useCase.call(
        todoText: ' 문서 정리하기 ',
        existingTodo: null,
        userId: 5,
      );

      expect(repository.addTodoCallCount, 1);
      expect(repository.lastTodoText, '문서 정리하기');
      result.when(
        success: (todo) => expect(todo.id, 10),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('edit 성공 시 수정된 할 일을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..updateTodoResult = createTodo(id: 7, todo: '수정된 작업', userId: 5);
      final useCase = SaveTodoUseCase(repository);

      final result = await useCase.call(
        todoText: ' 수정된 작업 ',
        existingTodo: createTodo(id: 7, todo: '기존 작업', userId: 5),
        userId: null,
      );

      expect(repository.updateTodoCallCount, 1);
      expect(repository.lastTodoId, 7);
      expect(repository.lastTodoText, '수정된 작업');
      result.when(
        success: (todo) => expect(todo.todo, '수정된 작업'),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('빈 입력이면 validation 실패를 반환한다', () async {
      final useCase = SaveTodoUseCase(FakeTodosRepository());

      final result = await useCase.call(
        todoText: '   ',
        existingTodo: null,
        userId: 5,
      );

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '할 일 내용을 입력해 주세요.');
        },
      );
    });

    test('create 에서 userId가 없으면 validation 실패를 반환한다', () async {
      final useCase = SaveTodoUseCase(FakeTodosRepository());

      final result = await useCase.call(
        todoText: '새 작업',
        existingTodo: null,
        userId: null,
      );

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
        ..updateTodoResult = const AppException('network error');
      final useCase = SaveTodoUseCase(repository);

      final result = await useCase.call(
        todoText: '수정된 작업',
        existingTodo: createTodo(id: 7, todo: '기존 작업', userId: 5),
        userId: null,
      );

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
