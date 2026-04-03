import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/todos/application/current_todo_user_id_provider.dart';
import 'package:riverpod_origin_template/features/todos/application/todos_controller.dart';
import 'package:riverpod_origin_template/features/todos/domain/entities/todo.dart';
import 'package:riverpod_origin_template/features/todos/presentation/todos_screen.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  testWidgets('초기 로딩 중에는 할 일 추가 입력이 비활성화된다', (tester) async {
    final fetchRequest = Completer<List<Todo>>();
    final repository = FakeTodosRepository()
      ..fetchTodosResult = fetchRequest.future;
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        currentTodoUserIdProvider.overrideWithValue(5),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodosScreen()),
      ),
    );

    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.enabled, isFalse);

    await tester.tap(find.text('할 일 추가'), warnIfMissed: false);
    await tester.pump();
    expect(repository.addTodoCallCount, 0);

    fetchRequest.complete(<Todo>[createTodo(id: 1, todo: '기존 작업')]);
    await tester.pumpAndSettle();
  });

  testWidgets('할 일 화면은 목록을 렌더링하고 새 할 일을 추가할 수 있다', (tester) async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1, todo: '기존 작업')]
      ..addTodoResult = createTodo(id: 2, todo: '새 작업');
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        currentTodoUserIdProvider.overrideWithValue(5),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodosScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('할 일 관리'), findsOneWidget);
    expect(find.text('기존 작업'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '새 작업');
    await tester.tap(find.text('할 일 추가'));
    await tester.pumpAndSettle();

    expect(find.text('새 작업'), findsOneWidget);
    expect(find.text('기존 작업'), findsOneWidget);
  });

  testWidgets('새로고침 중에는 토글과 삭제 동작이 비활성화된다', (tester) async {
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1, todo: '기존 작업')];
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        currentTodoUserIdProvider.overrideWithValue(5),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodosScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final refreshRequest = Completer<List<Todo>>();
    repository.fetchTodosResult = refreshRequest.future;

    unawaited(container.read(todosControllerProvider.notifier).refresh());
    await tester.pump();

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    final deleteButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(checkbox.onChanged, isNull);
    expect(deleteButton.onPressed, isNull);

    refreshRequest.complete(<Todo>[createTodo(id: 1, todo: '기존 작업')]);
    await tester.pumpAndSettle();
  });

  testWidgets('추가 요청 중 화면이 dispose되어도 예외를 내지 않는다', (tester) async {
    final addRequest = Completer<Todo>();
    final repository = FakeTodosRepository()
      ..fetchTodosResult = <Todo>[createTodo(id: 1, todo: '기존 작업')]
      ..addTodoResult = addRequest.future;
    final container = ProviderContainer(
      overrides: [
        todosRepositoryProvider.overrideWithValue(repository),
        currentTodoUserIdProvider.overrideWithValue(5),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TodosScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '새 작업');
    await tester.tap(find.text('할 일 추가'));
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    addRequest.complete(createTodo(id: 2, todo: '새 작업', userId: 5));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
