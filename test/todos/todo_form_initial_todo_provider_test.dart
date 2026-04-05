import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/todos/application/todo_form_initial_todo_provider.dart';
import 'package:riverpod_origin_template/features/todos/application/todo_form_route_arguments_provider.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  test('state.extra 없이 edit 모드면 todoId 기반으로 상세를 조회한다', () async {
    final repository = FakeTodosRepository()
      ..fetchTodoDetailResult = createTodo(id: 7, todo: '기존 작업', userId: 5);
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        todoFormRouteArgumentsProvider.overrideWithValue(
          const TodoFormRouteArguments.edit(todoId: 7),
        ),
      ],
    );
    addTearDown(container.dispose);

    final todo = await container.read(todoFormInitialTodoProvider.future);

    expect(todo?.todo, '기존 작업');
    expect(repository.fetchTodoDetailCallCount, 1);
  });

  test('state.extra 가 있으면 상세 조회 없이 그대로 사용한다', () async {
    final repository = FakeTodosRepository();
    final initialTodo = createTodo(id: 7, todo: '기존 작업', userId: 5);
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        todoFormRouteArgumentsProvider.overrideWithValue(
          TodoFormRouteArguments.edit(todoId: 7, initialTodo: initialTodo),
        ),
      ],
    );
    addTearDown(container.dispose);

    final todo = await container.read(todoFormInitialTodoProvider.future);

    expect(todo, initialTodo);
    expect(repository.fetchTodoDetailCallCount, 0);
  });
}
