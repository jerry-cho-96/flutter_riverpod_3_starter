import 'package:go_router/go_router.dart';

import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/home/presentation/screens/invalid_product_detail_screen.dart';
import '../../../features/home/presentation/screens/product_detail_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildHomeRouteModule() {
  return <RouteBase>[
    GoRoute(
      path: AppRoute.home.path,
      name: AppRoute.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoute.productDetail.path,
      name: AppRoute.productDetail.name,
      builder: (context, state) {
        final productId = int.tryParse(state.pathParameters['productId'] ?? '');
        if (productId == null || productId <= 0) {
          return const InvalidProductDetailScreen();
        }

        return ProductDetailScreen(productId: productId);
      },
    ),
  ];
}
