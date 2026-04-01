import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/home/application/usecases/get_product_detail_use_case.dart';

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
  });
}
