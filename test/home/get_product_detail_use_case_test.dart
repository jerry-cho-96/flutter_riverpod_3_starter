import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/result/result.dart';
import 'package:riverpod_origin_template/features/home/application/usecases/get_product_detail_use_case.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('GetProductDetailUseCase', () {
    test('유효하지 않은 상품 id 면 validation 실패를 반환한다', () async {
      final repository = FakeProductsRepository();
      final useCase = GetProductDetailUseCase(repository);

      final result = await useCase.call(productId: 0);

      expect(repository.fetchProductDetailCallCount, 0);
      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 상품 경로가 아닙니다.');
        },
      );
    });

    test('성공 시 상품 상세를 반환한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductDetailResult = createProduct(id: 9, title: 'Monitor Arm');
      final useCase = GetProductDetailUseCase(repository);

      final result = await useCase.call(productId: 9);

      expect(repository.fetchProductDetailCallCount, 1);
      expect(repository.lastProductId, 9);
      result.when(
        success: (product) => expect(product.title, 'Monitor Arm'),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductDetailResult = const AppException('network error');
      final useCase = GetProductDetailUseCase(repository);

      final result = await useCase.call(productId: 3);

      result.when(
        success: (_) => fail('network 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.network);
          expect(error.message, 'network error');
        },
      );
    });

    test('같은 상품 상세 요청은 성공 결과를 캐시한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductDetailResult = createProduct(id: 9, title: 'Monitor Arm');
      final useCase = GetProductDetailUseCase(repository);

      await useCase.call(productId: 9);
      final secondResult = await useCase.call(productId: 9);

      expect(repository.fetchProductDetailCallCount, 1);
      secondResult.when(
        success: (product) => expect(product.title, 'Monitor Arm'),
        failure: (_) => fail('캐시된 성공 결과가 예상됩니다.'),
      );
    });

    test('clearCache 후에는 같은 상품 상세도 다시 조회한다', () async {
      final repository = FakeProductsRepository()
        ..fetchProductDetailResult = createProduct(id: 9, title: 'Monitor Arm');
      final useCase = GetProductDetailUseCase(repository);

      await useCase.call(productId: 9);
      repository.fetchProductDetailResult = createProduct(
        id: 9,
        title: 'Desk Shelf',
      );
      useCase.clearCache(productId: 9);
      final refreshedResult = await useCase.call(productId: 9);

      expect(repository.fetchProductDetailCallCount, 2);
      refreshedResult.when(
        success: (product) => expect(product.title, 'Desk Shelf'),
        failure: (_) => fail('캐시 무효화 후 재조회 성공이 예상됩니다.'),
      );
    });

    test('같은 상품 상세 요청은 진행 중 fetch 를 재사용한다', () async {
      final repository = _QueuedProductDetailRepository();
      final pendingRequest = Completer<Product>();
      repository.enqueue(pendingRequest);
      final useCase = GetProductDetailUseCase(repository);

      final firstFuture = useCase.call(productId: 7);
      final secondFuture = useCase.call(productId: 7);
      pendingRequest.complete(createProduct(id: 7, title: 'Desk Shelf'));
      final results = await Future.wait<Result<Product>>(
        <Future<Result<Product>>>[firstFuture, secondFuture],
      );

      expect(repository.fetchProductDetailCallCount, 1);
      for (final result in results) {
        result.when(
          success: (product) => expect(product.title, 'Desk Shelf'),
          failure: (_) => fail('중복 제거된 성공 결과가 예상됩니다.'),
        );
      }
    });
  });
}

class _QueuedProductDetailRepository extends FakeProductsRepository {
  final List<Completer<Product>> _requests = <Completer<Product>>[];

  void enqueue(Completer<Product> request) {
    _requests.add(request);
  }

  @override
  Future<Product> fetchProductDetail({required int productId}) {
    fetchProductDetailCallCount += 1;
    lastProductId = productId;
    if (_requests.isEmpty) {
      throw StateError('No queued detail request configured');
    }

    return _requests.removeAt(0).future;
  }
}
