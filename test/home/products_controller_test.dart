import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:riverpod_origin_template/core/pagination/paginated_list_state.dart';
import 'package:riverpod_origin_template/features/home/application/products_provider.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';
import 'package:riverpod_origin_template/features/home/domain/repositories/products_repository.dart';
import 'package:riverpod_origin_template/features/home/home_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedProductsRepository();
    final firstRequest = Completer<PageChunk<Product>>();
    final secondRequest = Completer<PageChunk<Product>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container
        .listen<AsyncValue<PaginatedListState<Product>>>(
          productsControllerProvider,
          (previous, next) {},
        );
    addTearDown(subscription.close);

    final initialFuture = container.read(productsControllerProvider.future);
    firstRequest.complete(createProductPage(items: <Product>[createProduct()]));
    await initialFuture;

    final refreshFuture = container
        .read(productsControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    unawaited(refreshFuture.then((_) => refreshCompleted = true));
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.isLoading, isTrue);
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue.items, <Product>[createProduct()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(
      createProductPage(items: <Product>[createProduct(id: 2)]),
    );
    await refreshFuture;

    expect(subscription.read().hasValue, isTrue);
    expect(subscription.read().hasError, isFalse);
    expect(subscription.read().requireValue.items, <Product>[
      createProduct(id: 2),
    ]);
  });

  test('loadMore 성공 시 다음 페이지를 이어 붙인다', () async {
    final repository = _QueuedProductsRepository();
    final firstRequest = Completer<PageChunk<Product>>();
    final secondRequest = Completer<PageChunk<Product>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initialFuture = container.read(productsControllerProvider.future);
    firstRequest.complete(
      createProductPage(
        items: List<Product>.generate(
          20,
          (index) => createProduct(id: index + 1),
        ),
        total: 21,
      ),
    );
    await initialFuture;

    final loadMoreFuture = container
        .read(productsControllerProvider.notifier)
        .loadMore();
    secondRequest.complete(
      createProductPage(
        items: <Product>[createProduct(id: 21)],
        total: 21,
        skip: 20,
      ),
    );
    await loadMoreFuture;

    final pageState = container.read(productsControllerProvider).requireValue;
    expect(pageState.items, hasLength(21));
    expect(pageState.items.last.id, 21);
    expect(pageState.hasMore, isFalse);
  });

  test('loadMore 실패 시 기존 목록을 유지하고 실패를 보존한다', () async {
    final repository = _QueuedProductsRepository();
    final firstRequest = Completer<PageChunk<Product>>();
    final secondRequest = Completer<PageChunk<Product>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initialFuture = container.read(productsControllerProvider.future);
    firstRequest.complete(
      createProductPage(
        items: List<Product>.generate(
          20,
          (index) => createProduct(id: index + 1),
        ),
        total: 21,
      ),
    );
    await initialFuture;

    final loadMoreFuture = container
        .read(productsControllerProvider.notifier)
        .loadMore();
    secondRequest.completeError(const AppException('network error'));
    await loadMoreFuture;

    final pageState = container.read(productsControllerProvider).requireValue;
    expect(pageState.items, hasLength(20));
    expect(
      pageState.loadMoreFailure,
      const AppFailure(message: 'network error', type: FailureType.network),
    );
  });
}

class _QueuedProductsRepository implements ProductsRepository {
  final List<Completer<PageChunk<Product>>> _requests =
      <Completer<PageChunk<Product>>>[];

  void enqueue(Completer<PageChunk<Product>> request) {
    _requests.add(request);
  }

  @override
  Future<PageChunk<Product>> fetchProducts({
    required int limit,
    required int skip,
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
