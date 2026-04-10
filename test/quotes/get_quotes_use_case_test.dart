import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:riverpod_origin_template/core/result/result.dart';
import 'package:riverpod_origin_template/features/quotes/application/usecases/get_quotes_use_case.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('GetQuotesUseCase', () {
    test('성공 시 명언 목록을 반환하고 요청 파라미터를 전달한다', () async {
      final quotes = <Quote>[createQuote(), createQuote(id: 2, author: 'AI')];
      final repository = FakeQuotesRepository()
        ..fetchQuotesResult = createQuotePage(items: quotes, total: 42);
      final useCase = GetQuotesUseCase(repository);

      final result = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchQuotesCallCount, 1);
      expect(repository.lastLimit, 20);
      expect(repository.lastSkip, 0);
      result.when(
        success: (value) {
          expect(value.items, hasLength(2));
          expect(value.total, 42);
        },
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

    test('같은 요청은 명언 목록 결과를 캐시한다', () async {
      final quotes = <Quote>[createQuote(), createQuote(id: 2, author: 'AI')];
      final repository = FakeQuotesRepository()
        ..fetchQuotesResult = createQuotePage(items: quotes, total: 42);
      final useCase = GetQuotesUseCase(repository);

      await useCase.call(limit: 20, skip: 0);
      final secondResult = await useCase.call(limit: 20, skip: 0);

      expect(repository.fetchQuotesCallCount, 1);
      secondResult.when(
        success: (value) => expect(value.items, quotes),
        failure: (_) => fail('캐시된 성공 결과가 예상됩니다.'),
      );
    });

    test('같은 진행 중 명언 요청은 하나의 fetch 를 재사용한다', () async {
      final repository = _QueuedQuotesRepository();
      final pendingRequest = Completer<PageChunk<Quote>>();
      repository.enqueue(pendingRequest);
      final useCase = GetQuotesUseCase(repository);

      final firstFuture = useCase.call(limit: 20, skip: 0);
      final secondFuture = useCase.call(limit: 20, skip: 0);
      pendingRequest.complete(
        createQuotePage(
          items: <Quote>[createQuote(id: 3, author: 'Architect')],
          total: 30,
        ),
      );

      final results = await Future.wait<Result<PageChunk<Quote>>>(
        <Future<Result<PageChunk<Quote>>>>[firstFuture, secondFuture],
      );

      expect(repository.fetchQuotesCallCount, 1);
      for (final result in results) {
        result.when(
          success: (value) {
            expect(value.items.single.author, 'Architect');
            expect(value.total, 30);
          },
          failure: (_) => fail('중복 제거된 성공 결과가 예상됩니다.'),
        );
      }
    });
  });
}

class _QueuedQuotesRepository extends FakeQuotesRepository {
  final List<Completer<PageChunk<Quote>>> _requests =
      <Completer<PageChunk<Quote>>>[];

  void enqueue(Completer<PageChunk<Quote>> request) {
    _requests.add(request);
  }

  @override
  Future<PageChunk<Quote>> fetchQuotes({
    required int limit,
    required int skip,
  }) {
    fetchQuotesCallCount += 1;
    lastLimit = limit;
    lastSkip = skip;
    if (_requests.isEmpty) {
      throw StateError('No queued quotes request configured');
    }

    return _requests.removeAt(0).future;
  }
}
