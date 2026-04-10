import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/pagination/page_chunk.dart';
import '../../../../core/result/query_result_cache.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../home_providers.dart';

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productsRepositoryProvider));
});

class GetProductsUseCase {
  GetProductsUseCase(this._repository);

  final ProductsRepository _repository;
  final QueryResultCache<(int, int), Result<PageChunk<Product>>> _cache =
      QueryResultCache<(int, int), Result<PageChunk<Product>>>();

  Future<Result<PageChunk<Product>>> call({
    required int limit,
    required int skip,
  }) async {
    return _cache.run((limit, skip), () async {
      try {
        final page = await _repository.fetchProducts(limit: limit, skip: skip);
        return Success<PageChunk<Product>>(page);
      } on AppException catch (error) {
        return Failure<PageChunk<Product>>(AppFailure.fromAppException(error));
      } catch (error) {
        return Failure<PageChunk<Product>>(
          AppFailure.fromObject(error, fallbackMessage: '상품 목록을 불러오지 못했습니다.'),
        );
      }
    }, shouldCache: (result) => result is Success<PageChunk<Product>>);
  }

  void clearCache() {
    _cache.clear();
  }
}
