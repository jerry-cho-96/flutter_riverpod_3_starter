import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../home_providers.dart';

final getProductDetailUseCaseProvider = Provider<GetProductDetailUseCase>((
  ref,
) {
  return GetProductDetailUseCase(ref.watch(productsRepositoryProvider));
});

class GetProductDetailUseCase {
  const GetProductDetailUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<Product>> call({required int productId}) async {
    if (productId <= 0) {
      return const Failure<Product>(
        AppFailure(message: '유효한 상품 경로가 아닙니다.', type: FailureType.validation),
      );
    }

    try {
      final product = await _repository.fetchProductDetail(
        productId: productId,
      );
      return Success<Product>(product);
    } on AppException catch (error) {
      return Failure<Product>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<Product>(
        AppFailure.fromObject(error, fallbackMessage: '상품 상세 정보를 불러오지 못했습니다.'),
      );
    }
  }
}
