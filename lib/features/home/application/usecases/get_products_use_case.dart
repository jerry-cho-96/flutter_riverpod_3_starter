import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../../home_providers.dart';

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
});

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Result<ProductPage>> call({
    required int limit,
    required int skip,
    String? query,
  }) async {
    if (limit <= 0 || skip < 0) {
      return const Failure<ProductPage>(
        AppFailure(
          message: '유효한 상품 목록 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final productsPage = await _repository.fetchProducts(
        limit: limit,
        skip: skip,
        query: query?.trim().isEmpty ?? true ? null : query?.trim(),
      );
      return Success<ProductPage>(productsPage);
    } on AppException catch (error) {
      return Failure<ProductPage>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<ProductPage>(
        AppFailure.fromObject(error, fallbackMessage: '상품 목록을 불러오지 못했습니다.'),
      );
    }
  }
}
