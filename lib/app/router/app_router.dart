import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/controllers/session_controller.dart';
import 'app_route_guard.dart';
import 'app_routes.dart';
import 'router_refresh_listenable.dart';
import 'route_modules/auth_route_module.dart';
import 'route_modules/home_route_module.dart';
import 'route_modules/quotes_route_module.dart';
import 'route_modules/todos_route_module.dart';
import 'widgets/authenticated_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: refreshListenable,
    routes: <RouteBase>[
      ...buildAuthRouteModule(),
      ShellRoute(
        builder: (context, state, child) => AuthenticatedShell(child: child),
        routes: <RouteBase>[
          ...buildHomeRouteModule(),
          ...buildQuotesRouteModule(),
          ...buildTodosRouteModule(),
        ],
      ),
    ],
    redirect: (context, state) {
      final sessionState = ref.read(sessionControllerProvider);
      return AppRouteGuard.redirect(sessionState: sessionState, uri: state.uri);
    },
  );
});
