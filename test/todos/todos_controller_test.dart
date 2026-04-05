import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/todos/application/current_todo_user_id_provider.dart';
import 'package:riverpod_origin_template/features/todos/application/todos_controller.dart';
import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';
import 'package:riverpod_origin_template/features/todos/domain/repositories/todos_repository.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedTodosRepository();
    final firstRequest = Completer<List<Todo>>();
    final secondRequest = Completer<List<Todo>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = await _createContainer(repository);
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<List<Todo>>>(
      todosControllerProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final initialFuture = container.read(todosControllerProvider.future);
    firstRequest.complete(<Todo>[createTodo()]);
    await initialFuture;

    final refreshFuture = container
        .read(todosControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    refreshFuture.then((_) => refreshCompleted = true);
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.isLoading, isTrue);
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue, <Todo>[createTodo()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(<Todo>[createTodo(id: 2)]);
    await refreshFuture;

    expect(subscription.read().requireValue, <Todo>[createTodo(id: 2)]);
  });

  test('addTodo 성공 시 목록 앞에 새 할 일을 추가한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1)]
      ..addTodoResult = createTodo(id: 2, todo: '문서 정리하기');
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container.read(todosControllerProvider.notifier).addTodo('문서 정리하기');

    expect(container.read(todosControllerProvider).requireValue, <Todo>[
      createTodo(id: 2, todo: '문서 정리하기'),
      createTodo(id: 1),
    ]);
  });

  test('초기 로딩 중 addTodo가 발생해도 새 할 일을 유지한다', () async {
    final fetchRequest = Completer<List<Todo>>();
    final repository = FakeTodosRepository()
      ..fetchTodosResult = fetchRequest.future
      ..addTodoResult = createTodo(id: 2, todo: '새 작업', userId: 5);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    final initialFuture = container.read(todosControllerProvider.future);
    await Future<void>.delayed(Duration.zero);

    await container.read(todosControllerProvider.notifier).addTodo('새 작업');
    fetchRequest.complete(<Todo>[createTodo(id: 1)]);
    await initialFuture;

    expect(container.read(todosControllerProvider).requireValue, <Todo>[
      createTodo(id: 2, todo: '새 작업', userId: 5),
      createTodo(id: 1),
    ]);
  });

  test('stale refresh가 와도 직전 addTodo 결과를 유지한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1)]
      ..addTodoResult = createTodo(id: 2, todo: '새 작업', userId: 5);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container.read(todosControllerProvider.notifier).addTodo('새 작업');

    repository.fetchTodosResult = <Todo>[createTodo(id: 1)];
    await container.read(todosControllerProvider.notifier).refresh();

    expect(container.read(todosControllerProvider).requireValue, <Todo>[
      createTodo(id: 2, todo: '새 작업', userId: 5),
      createTodo(id: 1),
    ]);
  });

  test('toggleTodoCompletion 성공 시 해당 항목 상태를 갱신한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1, completed: false)]
      ..updateTodoResult = createTodo(id: 1, completed: true);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container
        .read(todosControllerProvider.notifier)
        .toggleTodoCompletion(createTodo(id: 1, completed: false));

    expect(
      container.read(todosControllerProvider).requireValue.single.completed,
      isTrue,
    );
  });

  test('local-only todo 는 toggle 시 API 호출 없이 로컬 상태만 갱신한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1)]
      ..addTodoResult = createTodo(id: 255, todo: '새 작업', userId: 5);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container.read(todosControllerProvider.notifier).addTodo('새 작업');
    await container
        .read(todosControllerProvider.notifier)
        .toggleTodoCompletion(createTodo(id: 255, todo: '새 작업', userId: 5));

    expect(repository.updateTodoCallCount, 0);
    expect(
      container.read(todosControllerProvider).requireValue.first,
      createTodo(id: 255, todo: '새 작업', completed: true, userId: 5),
    );
  });

  test('deleteTodo 성공 시 해당 항목을 목록에서 제거한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1), createTodo(id: 2)]
      ..deleteTodoResult = createTodo(id: 1);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container
        .read(todosControllerProvider.notifier)
        .deleteTodo(createTodo(id: 1));

    expect(container.read(todosControllerProvider).requireValue, <Todo>[
      createTodo(id: 2),
    ]);
  });

  test('local-only todo 는 delete 시 API 호출 없이 로컬 목록에서 제거한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1)]
      ..addTodoResult = createTodo(id: 255, todo: '새 작업', userId: 5);
    final container = await _createContainer(repository);
    addTearDown(container.dispose);

    await container.read(todosControllerProvider.future);
    await container.read(todosControllerProvider.notifier).addTodo('새 작업');
    await container
        .read(todosControllerProvider.notifier)
        .deleteTodo(createTodo(id: 255, todo: '새 작업', userId: 5));

    expect(repository.deleteTodoCallCount, 0);
    expect(container.read(todosControllerProvider).requireValue, <Todo>[
      createTodo(id: 1),
    ]);
  });
}

Future<ProviderContainer> _createContainer(TodosRepository repository) async {
  return ProviderContainer(
    overrides: [
      todosRepositoryProvider.overrideWithValue(repository),
      currentTodoUserIdProvider.overrideWithValue(5),
    ],
  );
}

class _QueuedTodosRepository implements TodosRepository {
  final List<Completer<List<Todo>>> _requests = <Completer<List<Todo>>>[];

  void enqueue(Completer<List<Todo>> request) {
    _requests.add(request);
  }

  @override
  Future<Todo> addTodo({required int userId, required String todo}) {
    throw UnimplementedError('할 일 추가는 이 테스트에서 사용하지 않습니다.');
  }

  @override
  Future<Todo> deleteTodo({required int todoId}) {
    throw UnimplementedError('할 일 삭제는 이 테스트에서 사용하지 않습니다.');
  }

  @override
  Future<List<Todo>> fetchTodosByUser({
    required int userId,
    required int limit,
    required int skip,
  }) {
    if (_requests.isEmpty) {
      throw StateError('No queued todos request configured');
    }

    return _requests.removeAt(0).future;
  }

  @override
  Future<Todo> fetchTodoDetail({required int todoId}) {
    throw UnimplementedError('할 일 상세 조회는 이 테스트에서 사용하지 않습니다.');
  }

  @override
  Future<Todo> updateTodo({
    required int todoId,
    String? todo,
    bool? completed,
  }) {
    throw UnimplementedError('할 일 수정은 이 테스트에서 사용하지 않습니다.');
  }
}
