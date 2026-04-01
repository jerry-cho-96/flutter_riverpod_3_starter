import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/application/product_detail_argument_provider.dart';
import 'package:riverpod_origin_template/features/home/application/product_detail_controller.dart';
import 'package:riverpod_origin_template/features/home/home_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('argument provider 로 전달된 productId 로 상세를 조회한다', () async {
    final repository = FakeProductsRepository()
      ..fetchProductDetailResult = createProduct(id: 7, title: 'Desk Shelf');
    final container = ProviderContainer(
      overrides: [
        productsRepositoryProvider.overrideWithValue(repository),
        productDetailArgumentProvider.overrideWithValue(7),
      ],
    );
    addTearDown(container.dispose);

    final product = await container.read(
      productDetailControllerProvider.future,
    );

    expect(repository.fetchProductDetailCallCount, 1);
    expect(repository.lastProductId, 7);
    expect(product.title, 'Desk Shelf');
  });
}
