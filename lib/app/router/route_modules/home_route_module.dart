import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/home/presentation/product_detail_screen.dart';
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
      GoRoute(
        path: AppRoute.productDetail.path,
        name: AppRoute.productDetail.name,
        builder: (context, state) {
          final productId = int.tryParse(
            state.pathParameters['productId'] ?? '',
          );
          if (productId == null || productId <= 0) {
            return const _InvalidProductDetailScreen();
          }

          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
  );
}

class _InvalidProductDetailScreen extends StatelessWidget {
  const _InvalidProductDetailScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('유효하지 않은 상품 경로입니다.'));
  }
}
