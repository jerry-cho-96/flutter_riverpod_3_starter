import 'dart:async';

import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/result/result.dart';
import 'package:riverpod_origin_template/features/todos/application/usecases/get_todos_use_case.dart';
import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';

import 'fakes.dart';

void main() {
  group('GetTodosUseCase', () {
    test('성공 시 사용자 할 일 목록을 반환한다', () async {
      final repository = FakeTodosRepository()
        ..fetchTodosResult = createTodoPage(
          items: [createTodo(id: 1, userId: 5), createTodo(id: 2, userId: 5)],
          total: 42,
        );
      final useCase = GetTodosUseCase(repository);

      final result = await useCase.call(userId: 5, limit: 20, skip: 0);

      expect(repository.fetchTodosCallCount, 1);
      expect(repository.lastUserId, 5);
      result.when(
        success: (page) {
          expect(page, isA<PageChunk<dynamic>>());
          expect(page.items, hasLength(2));
          expect(page.total, 42);
        },
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

    test('같은 요청은 성공 결과를 캐시한다', () async {
      final todos = <Todo>[
        createTodo(id: 1, userId: 5),
        createTodo(id: 2, userId: 5),
      ];
      final repository = FakeTodosRepository()
        ..fetchTodosResult = createTodoPage(items: todos, total: 42);
      final useCase = GetTodosUseCase(repository);

      await useCase.call(userId: 5, limit: 20, skip: 0);
      final secondResult = await useCase.call(userId: 5, limit: 20, skip: 0);

      expect(repository.fetchTodosCallCount, 1);
      secondResult.when(
        success: (page) => expect(page.items, todos),
        failure: (_) => fail('캐시된 성공 결과가 예상됩니다.'),
      );
    });

    test('같은 진행 중 요청은 하나의 fetch 를 재사용한다', () async {
      final repository = _QueuedTodosRepository();
      final pendingRequest = Completer<PageChunk<Todo>>();
      repository.enqueue(pendingRequest);
      final useCase = GetTodosUseCase(repository);

      final firstFuture = useCase.call(userId: 5, limit: 20, skip: 0);
      final secondFuture = useCase.call(userId: 5, limit: 20, skip: 0);
      pendingRequest.complete(
        createTodoPage(items: <Todo>[createTodo(id: 3, userId: 5)], total: 30),
      );

      final results = await Future.wait<Result<PageChunk<Todo>>>(
        <Future<Result<PageChunk<Todo>>>>[firstFuture, secondFuture],
      );

      expect(repository.fetchTodosCallCount, 1);
      for (final result in results) {
        result.when(
          success: (page) {
            expect(page.items.single.id, 3);
            expect(page.total, 30);
          },
          failure: (_) => fail('중복 제거된 성공 결과가 예상됩니다.'),
        );
      }
    });
  });
}

class _QueuedTodosRepository extends FakeTodosRepository {
  final List<Completer<PageChunk<Todo>>> _requests =
      <Completer<PageChunk<Todo>>>[];

  void enqueue(Completer<PageChunk<Todo>> request) {
    _requests.add(request);
  }

  @override
  Future<PageChunk<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) {
    fetchTodosCallCount += 1;
    lastUserId = userId;
    lastLimit = limit;
    lastSkip = skip;
    if (_requests.isEmpty) {
      throw StateError('No queued todos request configured');
    }

    return _requests.removeAt(0).future;
  }
}
