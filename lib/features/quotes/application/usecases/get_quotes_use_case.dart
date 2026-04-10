import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/pagination/page_chunk.dart';
import '../../../../core/result/query_result_cache.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../../quotes_providers.dart';

final getQuotesUseCaseProvider = Provider<GetQuotesUseCase>((ref) {
  return GetQuotesUseCase(ref.watch(quotesRepositoryProvider));
});

class GetQuotesUseCase {
  GetQuotesUseCase(this._repository);

  final QuotesRepository _repository;
  final QueryResultCache<(int, int), Result<PageChunk<Quote>>> _cache =
      QueryResultCache<(int, int), Result<PageChunk<Quote>>>();

  Future<Result<PageChunk<Quote>>> call({
    required int limit,
    required int skip,
  }) async {
    if (limit <= 0 || skip < 0) {
      return const Failure<PageChunk<Quote>>(
        AppFailure(
          message: '유효한 명언 목록 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    return _cache.run((limit, skip), () async {
      try {
        final page = await _repository.fetchQuotes(limit: limit, skip: skip);
        return Success<PageChunk<Quote>>(page);
      } on AppException catch (error) {
        return Failure<PageChunk<Quote>>(AppFailure.fromAppException(error));
      } catch (error) {
        return Failure<PageChunk<Quote>>(
          AppFailure.fromObject(error, fallbackMessage: '명언 목록을 불러오지 못했습니다.'),
        );
      }
    }, shouldCache: (result) => result is Success<PageChunk<Quote>>);
  }

  void clearCache() {
    _cache.clear();
  }
}
