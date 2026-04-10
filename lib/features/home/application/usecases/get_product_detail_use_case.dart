import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/query_result_cache.dart';
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
  GetProductDetailUseCase(this._repository);

  final ProductsRepository _repository;
  final QueryResultCache<int, Result<Product>> _cache =
      QueryResultCache<int, Result<Product>>();

  Future<Result<Product>> call({required int productId}) async {
    if (productId <= 0) {
      return const Failure<Product>(
        AppFailure(message: '유효한 상품 경로가 아닙니다.', type: FailureType.validation),
      );
    }

    return _cache.run(productId, () async {
      try {
        final product = await _repository.fetchProductDetail(
          productId: productId,
        );
        return Success<Product>(product);
      } on AppException catch (error) {
        return Failure<Product>(AppFailure.fromAppException(error));
      } catch (error) {
        return Failure<Product>(
          AppFailure.fromObject(
            error,
            fallbackMessage: '상품 상세 정보를 불러오지 못했습니다.',
          ),
        );
      }
    }, shouldCache: (result) => result is Success<Product>);
  }

  void clearCache({int? productId}) {
    if (productId == null) {
      _cache.clear();
      return;
    }

    _cache.invalidate(productId);
  }
}
