import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../../quotes_providers.dart';

final getQuotesUseCaseProvider = Provider<GetQuotesUseCase>((ref) {
  return GetQuotesUseCase(ref.watch(quotesRepositoryProvider));
});

class GetQuotesUseCase {
  const GetQuotesUseCase(this._repository);

  final QuotesRepository _repository;

  Future<Result<List<Quote>>> call({
    required int limit,
    required int skip,
  }) async {
    if (limit <= 0 || skip < 0) {
      return const Failure<List<Quote>>(
        AppFailure(
          message: '유효한 명언 목록 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final quotes = await _repository.fetchQuotes(limit: limit, skip: skip);
      return Success<List<Quote>>(quotes);
    } on AppException catch (error) {
      return Failure<List<Quote>>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<List<Quote>>(
        AppFailure.fromObject(error, fallbackMessage: '명언 목록을 불러오지 못했습니다.'),
      );
    }
  }
}
