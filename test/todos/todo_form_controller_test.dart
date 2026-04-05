import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/todos/application/current_todo_user_id_provider.dart';
import 'package:riverpod_origin_template/features/todos/application/todo_form_controller.dart';
import 'package:riverpod_origin_template/features/todos/application/todo_form_route_arguments_provider.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  test('create submit 성공 시 새 할 일을 반환한다', () async {
    final repository = FakeTodosRepository()
      ..addTodoResult = createTodo(id: 22, todo: '새 작업', userId: 5);
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        currentTodoUserIdProvider.overrideWithValue(5),
        todoFormRouteArgumentsProvider.overrideWithValue(
          const TodoFormRouteArguments.create(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final savedTodo = await container
        .read(todoFormControllerProvider.notifier)
        .submit('새 작업', existingTodo: null);

    expect(savedTodo.id, 22);
    expect(container.read(todoFormControllerProvider).isLoading, isFalse);
  });

  test('edit submit 성공 시 수정된 할 일을 반환한다', () async {
    final repository = FakeTodosRepository()
      ..updateTodoResult = createTodo(id: 7, todo: '수정된 작업', userId: 5);
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        todoFormRouteArgumentsProvider.overrideWithValue(
          TodoFormRouteArguments.edit(
            todoId: 7,
            initialTodo: createTodo(id: 7, todo: '기존 작업', userId: 5),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final savedTodo = await container
        .read(todoFormControllerProvider.notifier)
        .submit(
          '수정된 작업',
          existingTodo: createTodo(id: 7, todo: '기존 작업', userId: 5),
        );

    expect(savedTodo.todo, '수정된 작업');
    expect(repository.lastTodoText, '수정된 작업');
  });

  test('validation 실패 시 loading 상태를 남기지 않는다', () async {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
        currentTodoUserIdProvider.overrideWithValue(5),
        todoFormRouteArgumentsProvider.overrideWithValue(
          const TodoFormRouteArguments.create(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(todoFormControllerProvider.notifier)
          .submit('   ', existingTodo: null),
      throwsA(isA<Object>()),
    );

    expect(container.read(todoFormControllerProvider).isLoading, isFalse);
  });
}
