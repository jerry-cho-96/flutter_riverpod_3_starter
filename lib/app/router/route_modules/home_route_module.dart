import 'package:go_router/go_router.dart';

import '../../../features/home/presentation/home_screen.dart';
import '../app_routes.dart';
import '../widgets/authenticated_shell.dart';

RouteBase buildHomeRouteModule() {
  return ShellRoute(
    builder: (context, state, child) => AuthenticatedShell(child: child),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
