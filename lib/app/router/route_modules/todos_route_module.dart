import 'package:go_router/go_router.dart';

import '../../../features/todos/presentation/todos_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildTodosRouteModule() {
  return <RouteBase>[
    GoRoute(
      path: AppRoute.todos.path,
      name: AppRoute.todos.name,
      builder: (context, state) => const TodosScreen(),
    ),
  ];
}
