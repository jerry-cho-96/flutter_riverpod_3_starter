import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/home/application/usecases/get_products_use_case.dart';
import 'package:riverpod_origin_template/features/home/domain/entities/product.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('GetProductsUseCase', () {
    test('성공 시 상품 목록을 반환하고 요청 파라미터를 전달한다', () async {
      final products = <Product>[createProduct(), createProduct(id: 2)];
      final repository = FakeProductsRepository()
        ..fetchProductsResult = products;
      final useCase = GetProductsUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchProductsCallCount, 1);
      expect(repository.lastLimit, 20);
      expect(repository.lastSkip, 0);
      result.when(
        success: (value) => expect(value, hasLength(2)),
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
  });
}
