import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/app_exception.dart';
import '../models/paginated_products_response_dto.dart';
import '../models/product_dto.dart';

final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((
  ref,
) {
  return ProductsRemoteDataSource(dio: ref.watch(dioProvider));
});

class ProductsRemoteDataSource {
  ProductsRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PaginatedProductsResponseDto> fetchProducts({
    required int limit,
    required int skip,
    String? query,
  }) async {
    try {
      final normalizedQuery = query?.trim();
      final hasQuery = normalizedQuery != null && normalizedQuery.isNotEmpty;
      final response = await _dio.get<Map<String, dynamic>>(
        hasQuery ? '/products/search' : '/products',
        queryParameters: <String, Object>{
          'limit': limit,
          'skip': skip,
          if (hasQuery) 'q': normalizedQuery,
        },
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('상품 목록 응답이 비어 있습니다.');
      }

      return PaginatedProductsResponseDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }

  Future<ProductDto> fetchProductDetail({required int productId}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products/$productId',
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('상품 상세 응답이 비어 있습니다.');
      }

      return ProductDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }
}
