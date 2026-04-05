import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_origin_template/app/router/app_routes.dart';
import 'package:riverpod_origin_template/app/router/route_modules/todos_route_module.dart';
import 'package:riverpod_origin_template/features/todos/application/current_todo_user_id_provider.dart';
import 'package:riverpod_origin_template/features/todos/presentation/todo_form_screen.dart';
import 'package:riverpod_origin_template/features/todos/todos_providers.dart';

import 'fakes.dart';

void main() {
  testWidgets('state.extra 없이 edit 경로로 직접 진입해도 form 화면을 복구한다', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoute.todoEdit.location(
        pathParameters: <String, String>{'todoId': '7'},
      ),
      routes: <RouteBase>[...buildTodosRouteModule()],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todosRepositoryProvider.overrideWithValue(FakeTodosRepository()),
          currentTodoUserIdProvider.overrideWithValue(5),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TodoFormScreen), findsOneWidget);
    expect(find.text('유효하지 않은 할 일 폼 경로입니다.'), findsNothing);
  });
}
