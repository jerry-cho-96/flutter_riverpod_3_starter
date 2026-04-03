import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/quotes/application/usecases/get_quotes_use_case.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('GetQuotesUseCase', () {
    test('성공 시 명언 목록을 반환하고 요청 파라미터를 전달한다', () async {
      final quotes = <Quote>[createQuote(), createQuote(id: 2, author: 'AI')];
      final repository = FakeQuotesRepository()..fetchQuotesResult = quotes;
      final useCase = GetQuotesUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchQuotesCallCount, 1);
      expect(repository.lastLimit, 20);
      expect(repository.lastSkip, 0);
      result.when(
        success: (value) => expect(value, hasLength(2)),
        failure: (_) => fail('성공 케이스가 예상됩니다.'),
      );
    });

    test('잘못된 요청이면 validation 실패를 반환한다', () async {
      final repository = FakeQuotesRepository();
      final useCase = GetQuotesUseCase(repository);

      final result = await useCase.call(limit: 0, skip: -1);

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '유효한 명언 목록 요청이 아닙니다.');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeQuotesRepository()
        ..fetchQuotesResult = const AppException('network error');
      final useCase = GetQuotesUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

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
