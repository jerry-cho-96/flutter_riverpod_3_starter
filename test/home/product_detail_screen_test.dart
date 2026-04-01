import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/presentation/product_detail_screen.dart';
import 'package:riverpod_origin_template/features/home/home_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  testWidgets('상세 화면은 page-scoped argument provider 와 상품 정보를 렌더링한다', (
    tester,
  ) async {
    final repository = FakeProductsRepository()
      ..fetchProductDetailResult = createProduct(id: 11, title: 'Studio Lamp');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProductDetailScreen(productId: 11)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('route productId=11'), findsOneWidget);
    expect(find.text('Studio Lamp'), findsOneWidget);
    expect(find.text('현재 정보 확인'), findsOneWidget);
  });
}
