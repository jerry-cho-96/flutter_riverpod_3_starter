import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:riverpod_origin_template/core/result/result.dart';
import 'package:riverpod_origin_template/features/home/application/usecases/get_products_use_case.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('GetProductsUseCase', () {
    test('성공 시 상품 목록을 반환하고 요청 파라미터를 전달한다', () async {
      final products = <Product>[createProduct(), createProduct(id: 2)];
      final repository = FakeProductsRepository()
        ..fetchProductsResult = createProductPage(items: products, total: 42);
      final useCase = GetProductsUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchProductsCallCount, 1);
      expect(repository.lastLimit, 20);
      expect(repository.lastSkip, 0);
      result.when(
        success: (value) {
          expect(value.items, hasLength(2));
          expect(value.total, 42);
        },
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductsResult = const AppException('network error');
      final useCase = GetProductsUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      result.when(
        success: (_) => fail('network 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.network);
          expect(error.message, 'network error');
        },
      );
    });

    test('서버 오류면 server 실패를 반환한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductsResult = const AppException(
          'server error',
          statusCode: 500,
        );
      final useCase = GetProductsUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      result.when(
        success: (_) => fail('server 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.server);
          expect(error.message, 'server error');
        },
      );
    });

    test('같은 요청은 성공 결과를 캐시한다', () async {
      final products = <Product>[createProduct(), createProduct(id: 2)];
      final repository = FakeProductsRepository()
        ..fetchProductsResult = createProductPage(items: products, total: 42);
      final useCase = GetProductsUseCase(repository);

      await useCase.call(limit: 20, skip: 0);
      final secondResult = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchProductsCallCount, 1);
      secondResult.when(
        success: (value) => expect(value.items, products),
        failure: (_) => fail('캐시된 성공 결과가 예상됩니다.'),
      );
    });

    test('같은 진행 중 요청은 하나의 fetch 를 재사용한다', () async {
      final repository = _QueuedProductsRepository();
      final pendingRequest = Completer<PageChunk<Product>>();
      repository.enqueue(pendingRequest);
      final useCase = GetProductsUseCase(repository);

      final firstFuture = useCase.call(limit: 20, skip: 0);
      final secondFuture = useCase.call(limit: 20, skip: 0);
      pendingRequest.complete(
        createProductPage(items: <Product>[createProduct(id: 5)], total: 30),
      );

      final results = await Future.wait<Result<PageChunk<Product>>>(
        <Future<Result<PageChunk<Product>>>>[firstFuture, secondFuture],
      );

      expect(repository.fetchProductsCallCount, 1);
      for (final result in results) {
        result.when(
          success: (value) {
            expect(value.items.single.id, 5);
            expect(value.total, 30);
          },
          failure: (_) => fail('중복 제거된 성공 결과가 예상됩니다.'),
        );
      }
    });
  });
}

class _QueuedProductsRepository extends FakeProductsRepository {
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
    fetchProductsCallCount += 1;
    lastLimit = limit;
    lastSkip = skip;
    if (_requests.isEmpty) {
      throw StateError('No queued products request configured');
    }

    return _requests.removeAt(0).future;
  }
}
