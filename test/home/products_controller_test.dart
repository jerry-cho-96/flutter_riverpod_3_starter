import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/application/products_provider.dart';
import 'package:riverpod_origin_template/features/home/application/products_state.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product_page.dart';
import 'package:riverpod_origin_template/features/home/domain/repositories/products_repository.dart';
import 'package:riverpod_origin_template/features/home/home_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedProductsRepository();
    final firstRequest = Completer<ProductPage>();
    final secondRequest = Completer<ProductPage>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<ProductsState>>(
      productsControllerProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final initialFuture = container.read(productsControllerProvider.future);
    firstRequest.complete(
      createProductPage(products: <Product>[createProduct()]),
    );
    await initialFuture;

    final refreshFuture = container
        .read(productsControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    refreshFuture.then((_) => refreshCompleted = true);
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue.isRefreshing, isTrue);
    expect(refreshingState.requireValue.products, <Product>[createProduct()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(
      createProductPage(products: <Product>[createProduct(id: 2)]),
    );
    await refreshFuture;

    expect(subscription.read().hasValue, isTrue);
    expect(subscription.read().hasError, isFalse);
    expect(subscription.read().requireValue.products, <Product>[
      createProduct(id: 2),
    ]);
  });

  test('search 시 query 를 반영해 첫 페이지를 다시 불러온다', () async {
    final repository = FakeProductsRepository()
      ..fetchProductsResult = createProductPage(
        products: <Product>[createProduct()],
      );
    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(productsControllerProvider.future);
    repository.fetchProductsResult = createProductPage(
      products: <Product>[createProduct(id: 2, title: 'Phone Case')],
      total: 1,
    );

    await container.read(productsControllerProvider.notifier).search(' phone ');

    final state = container.read(productsControllerProvider).requireValue;
    expect(repository.lastQuery, 'phone');
    expect(state.query, 'phone');
    expect(state.products, <Product>[
      createProduct(id: 2, title: 'Phone Case'),
    ]);
  });

  test('loadMore 성공 시 다음 페이지를 기존 목록 뒤에 이어 붙인다', () async {
    final repository = FakeProductsRepository()
      ..fetchProductsResult = createProductPage(
        products: <Product>[createProduct(id: 1), createProduct(id: 2)],
        total: 3,
      );
    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(productsControllerProvider.future);
    repository.fetchProductsResult = createProductPage(
      products: <Product>[createProduct(id: 3)],
      total: 3,
      skip: 2,
    );

    await container.read(productsControllerProvider.notifier).loadMore();

    final state = container.read(productsControllerProvider).requireValue;
    expect(repository.lastSkip, 2);
    expect(state.products, <Product>[
      createProduct(id: 1),
      createProduct(id: 2),
      createProduct(id: 3),
    ]);
    expect(state.hasMore, isFalse);
  });
}

class _QueuedProductsRepository implements ProductsRepository {
  final List<Completer<ProductPage>> _requests = <Completer<ProductPage>>[];

  void enqueue(Completer<ProductPage> request) {
    _requests.add(request);
  }

  @override
  Future<ProductPage> fetchProducts({
    required int limit,
    required int skip,
    String? query,
  }) {
    if (_requests.isEmpty) {
      throw StateError('No queued products request configured');
    }

    return _requests.removeAt(0).future;
  }

  @override
  Future<Product> fetchProductDetail({required int productId}) {
    throw UnimplementedError('상품 상세 조회는 이 테스트에서 사용하지 않습니다.');
  }
}
