import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/pagination/page_chunk.dart';
import 'package:riverpod_origin_template/core/pagination/paginated_list_state.dart';
import 'package:riverpod_origin_template/features/quotes/application/quotes_controller.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';
import 'package:riverpod_origin_template/features/quotes/domain/repositories/quotes_repository.dart';
import 'package:riverpod_origin_template/features/quotes/quotes_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedQuotesRepository();
    final firstRequest = Completer<PageChunk<Quote>>();
    final secondRequest = Completer<PageChunk<Quote>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [quotesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container
        .listen<AsyncValue<PaginatedListState<Quote>>>(
          quotesControllerProvider,
          (previous, next) {},
        );
    addTearDown(subscription.close);

    final initialFuture = container.read(quotesControllerProvider.future);
    firstRequest.complete(createQuotePage(items: <Quote>[createQuote()]));
    await initialFuture;

    final refreshFuture = container
        .read(quotesControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    unawaited(refreshFuture.then((_) => refreshCompleted = true));
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.isLoading, isTrue);
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue.items, <Quote>[createQuote()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(
      createQuotePage(items: <Quote>[createQuote(id: 2, author: 'Reviewer')]),
    );
    await refreshFuture;

    expect(subscription.read().hasValue, isTrue);
    expect(subscription.read().hasError, isFalse);
    expect(subscription.read().requireValue.items, <Quote>[
      createQuote(id: 2, author: 'Reviewer'),
    ]);
  });

  test('loadMore 성공 시 다음 페이지를 이어 붙인다', () async {
    final repository = _QueuedQuotesRepository();
    final firstRequest = Completer<PageChunk<Quote>>();
    final secondRequest = Completer<PageChunk<Quote>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [quotesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initialFuture = container.read(quotesControllerProvider.future);
    firstRequest.complete(
      createQuotePage(
        items: List<Quote>.generate(
          20,
          (index) => createQuote(id: index + 1, author: 'Author $index'),
        ),
        total: 21,
      ),
    );
    await initialFuture;

    final loadMoreFuture = container
        .read(quotesControllerProvider.notifier)
        .loadMore();
    secondRequest.complete(
      createQuotePage(
        items: <Quote>[createQuote(id: 21, author: 'Architect')],
        total: 21,
        skip: 20,
      ),
    );
    await loadMoreFuture;

    final pageState = container.read(quotesControllerProvider).requireValue;
    expect(pageState.items, hasLength(21));
    expect(pageState.items.last.author, 'Architect');
    expect(pageState.hasMore, isFalse);
  });

  test('loadMore 실패 시 기존 명언 목록을 유지하고 실패를 보존한다', () async {
    final repository = _QueuedQuotesRepository();
    final firstRequest = Completer<PageChunk<Quote>>();
    final secondRequest = Completer<PageChunk<Quote>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [quotesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final initialFuture = container.read(quotesControllerProvider.future);
    firstRequest.complete(
      createQuotePage(
        items: List<Quote>.generate(
          20,
          (index) => createQuote(id: index + 1, author: 'Author $index'),
        ),
        total: 21,
      ),
    );
    await initialFuture;

    final loadMoreFuture = container
        .read(quotesControllerProvider.notifier)
        .loadMore();
    secondRequest.completeError(const AppException('network error'));
    await loadMoreFuture;

    final pageState = container.read(quotesControllerProvider).requireValue;
    expect(pageState.items, hasLength(20));
    expect(
      pageState.loadMoreFailure,
      const AppFailure(message: 'network error', type: FailureType.network),
    );
  });
}

class _QueuedQuotesRepository implements QuotesRepository {
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
    if (_requests.isEmpty) {
      throw StateError('No queued quotes request configured');
    }

    return _requests.removeAt(0).future;
  }
}
