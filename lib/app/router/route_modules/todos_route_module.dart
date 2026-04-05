import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/todos/application/todo_form_route_arguments_provider.dart';
import '../../../features/todos/domain/entities/todo.dart';
import '../../../features/todos/presentation/invalid_todo_form_screen.dart';
import '../../../features/todos/presentation/todo_form_screen.dart';
import '../../../features/todos/presentation/todos_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildTodosRouteModule() {
  return <RouteBase>[
    GoRoute(
      path: AppRoute.todos.path,
      name: AppRoute.todos.name,
      builder: (context, state) => const TodosScreen(),
    ),
    GoRoute(
      path: AppRoute.todoCreate.path,
      name: AppRoute.todoCreate.name,
      builder: (context, state) {
        return ProviderScope(
          overrides: [
            todoFormRouteArgumentsProvider.overrideWithValue(
              const TodoFormRouteArguments.create(),
            ),
          ],
          child: const TodoFormScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoute.todoEdit.path,
      name: AppRoute.todoEdit.name,
      builder: (context, state) {
        final todoId = int.tryParse(state.pathParameters['todoId'] ?? '');
        if (todoId == null) {
          return const InvalidTodoFormScreen();
        }

        final todo = switch (state.extra) {
          Todo(:final id) when id == todoId => state.extra as Todo,
          _ => null,
        };

        return ProviderScope(
          overrides: [
            todoFormRouteArgumentsProvider.overrideWithValue(
              TodoFormRouteArguments.edit(todoId: todoId, initialTodo: todo),
            ),
          ],
          child: const TodoFormScreen(),
        );
      },
    ),
  ];
}
