import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/todos/application/current_todo_user_id_provider.dart';
import 'package:riverpod_origin_template/features/todos/application/todo_form_route_arguments_provider.dart';
import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';
import 'package:riverpod_origin_template/features/todos/presentation/todo_form_screen.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  testWidgets('create 모드에서 빈 입력 제출 시 validator 메시지를 노출한다', (tester) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodoFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('저장'));
    await tester.pump();

    expect(find.text('할 일 내용을 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('edit 모드에서는 기존 할 일 내용이 prefill 된다', (tester) async {
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
        todoFormRouteArgumentsProvider.overrideWithValue(
          TodoFormRouteArguments.edit(
            todoId: 7,
            initialTodo: createTodo(id: 7, todo: '기존 작업', userId: 5),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodoFormScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('할 일 수정'), findsNWidgets(2));
    expect(find.text('기존 작업'), findsOneWidget);
  });

  testWidgets('state.extra 없이 edit 모드로 열리면 상세를 조회해 prefill 한다', (tester) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodoFormScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('기존 작업'), findsOneWidget);
    expect(repository.fetchTodoDetailCallCount, 1);
  });

  testWidgets('edit 상세 조회 실패 시 에러 메시지를 노출한다', (tester) async {
    final repository = FakeTodosRepository()
      ..fetchTodoDetailResult = const AppException('상세 조회 실패');
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        todoFormRouteArgumentsProvider.overrideWithValue(
          const TodoFormRouteArguments.edit(todoId: 7),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodoFormScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('상세 조회 실패'), findsOneWidget);
    container.dispose();
  });

  testWidgets('submit 중에는 저장 버튼이 비활성화된다', (tester) async {
    final saveRequest = Completer<Todo>();
    final repository = FakeTodosRepository()
      ..addTodoResult = saveRequest.future;
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodoFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '새 작업');
    await tester.tap(find.text('저장'));
    await tester.pump();

    expect(find.text('저장 중...'), findsOneWidget);
    final saveButton = tester.widget<ButtonStyleButton>(
      find.bySubtype<ButtonStyleButton>(),
    );
    expect(saveButton.onPressed, isNull);

    saveRequest.complete(createTodo(id: 9, todo: '새 작업', userId: 5));
    await tester.pumpAndSettle();
  });
}
