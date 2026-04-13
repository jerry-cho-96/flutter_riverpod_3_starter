import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/application/controllers/product_detail_controller.dart';
import 'package:riverpod_origin_template/features/home/application/providers/product_detail_argument_provider.dart';
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

  test('refresh 시 대상 상품 상세 캐시를 비우고 다시 조회한다', () async {
    final repository = FakeProductsRepository()
      ..fetchProductDetailResult = createProduct(id: 7, title: 'Desk Shelf');
    final container = ProviderContainer(
      overrides: [
        productsRepositoryProvider.overrideWithValue(repository),
        productDetailArgumentProvider.overrideWithValue(7),
      ],
    );
    addTearDown(container.dispose);

    final firstProduct = await container.read(
      productDetailControllerProvider.future,
    );
    expect(firstProduct.title, 'Desk Shelf');

    repository.fetchProductDetailResult = createProduct(
      id: 7,
      title: 'Updated Shelf',
    );

    await container.read(productDetailControllerProvider.notifier).refresh();

    final refreshedProduct = container
        .read(productDetailControllerProvider)
        .requireValue;
    expect(repository.fetchProductDetailCallCount, 2);
    expect(refreshedProduct.title, 'Updated Shelf');
  });
}
