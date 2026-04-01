import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/home/application/products_provider.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';
import 'package:riverpod_origin_template/features/home/domain/repositories/products_repository.dart';
import 'package:riverpod_origin_template/features/home/home_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedProductsRepository();
    final firstRequest = Completer<List<Product>>();
    final secondRequest = Completer<List<Product>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<List<Product>>>(
      productsControllerProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final initialFuture = container.read(productsControllerProvider.future);
    firstRequest.complete(<Product>[createProduct()]);
    await initialFuture;

    final refreshFuture = container
        .read(productsControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    refreshFuture.then((_) => refreshCompleted = true);
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.isLoading, isTrue);
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue, <Product>[createProduct()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(<Product>[createProduct(id: 2)]);
    await refreshFuture;

    expect(subscription.read().hasValue, isTrue);
    expect(subscription.read().hasError, isFalse);
    expect(subscription.read().requireValue, <Product>[createProduct(id: 2)]);
  });
}

class _QueuedProductsRepository implements ProductsRepository {
  final List<Completer<List<Product>>> _requests = <Completer<List<Product>>>[];

  void enqueue(Completer<List<Product>> request) {
    _requests.add(request);
  }

  @override
  Future<List<Product>> fetchProducts({required int limit, required int skip}) {
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
