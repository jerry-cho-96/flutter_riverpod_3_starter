import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../home_providers.dart';

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
});

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<List<Product>>> call({
    required int limit,
    required int skip,
  }) async {
    try {
      final products = await _repository.fetchProducts(
        limit: limit,
        skip: skip,
      );
      return Success<List<Product>>(products);
    } on AppException catch (error) {
      return Failure<List<Product>>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<List<Product>>(
        AppFailure.fromObject(error, fallbackMessage: '상품 목록을 불러오지 못했습니다.'),
      );
    }
  }
}
