import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/session_controller.dart';
import 'app_route_guard.dart';
import 'app_routes.dart';
import 'router_refresh_listenable.dart';
import 'route_modules/auth_route_module.dart';
import 'route_modules/home_route_module.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: refreshListenable,
    routes: <RouteBase>[...buildAuthRouteModule(), buildHomeRouteModule()],
    redirect: (context, state) {
      final sessionState = ref.read(sessionControllerProvider);
      return AppRouteGuard.redirect(sessionState: sessionState, uri: state.uri);
    },
  );
});
