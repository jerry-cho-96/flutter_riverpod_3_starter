import 'package:go_router/go_router.dart';

import '../../../features/quotes/presentation/quotes_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildQuotesRouteModule() {
  return <RouteBase>[
    GoRoute(
      path: AppRoute.quotes.path,
      name: AppRoute.quotes.name,
      builder: (context, state) => const QuotesScreen(),
    ),
  ];
}
