import 'package:go_router/go_router.dart';

import '../../../features/home/presentation/home_screen.dart';
import '../../../features/home/presentation/invalid_product_detail_screen.dart';
import '../../../features/home/presentation/product_detail_screen.dart';
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
