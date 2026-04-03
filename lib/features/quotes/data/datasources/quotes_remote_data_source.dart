import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/app_exception.dart';
import '../models/paginated_quotes_response_dto.dart';

final quotesRemoteDataSourceProvider = Provider<QuotesRemoteDataSource>((ref) {
  return QuotesRemoteDataSource(dio: ref.watch(dioProvider));
});

class QuotesRemoteDataSource {
  QuotesRemoteDataSource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PaginatedQuotesResponseDto> fetchQuotes({
    required int limit,
    required int skip,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/quotes',
        queryParameters: <String, Object>{'limit': limit, 'skip': skip},
      );
      final json = response.data;
      if (json == null) {
        throw const AppException('명언 목록 응답이 비어 있습니다.');
      }

      return PaginatedQuotesResponseDto.fromJson(json);
    } on DioException catch (error) {
      throw AppException.fromDioException(error);
    }
  }
}
