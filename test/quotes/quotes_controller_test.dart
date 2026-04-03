import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/quotes/application/quotes_controller.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';
import 'package:riverpod_origin_template/features/quotes/domain/repositories/quotes_repository.dart';
import 'package:riverpod_origin_template/features/quotes/quotes_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  test('refresh 시 이전 목록을 유지한 채 새 요청을 시작한다', () async {
    final repository = _QueuedQuotesRepository();
    final firstRequest = Completer<List<Quote>>();
    final secondRequest = Completer<List<Quote>>();
    repository.enqueue(firstRequest);
    repository.enqueue(secondRequest);

    final container = ProviderContainer(
      overrides: [quotesRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<List<Quote>>>(
      quotesControllerProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);

    final initialFuture = container.read(quotesControllerProvider.future);
    firstRequest.complete(<Quote>[createQuote()]);
    await initialFuture;

    final refreshFuture = container
        .read(quotesControllerProvider.notifier)
        .refresh();
    var refreshCompleted = false;
    refreshFuture.then((_) => refreshCompleted = true);
    await Future<void>.delayed(Duration.zero);

    final refreshingState = subscription.read();
    expect(refreshingState.isLoading, isTrue);
    expect(refreshingState.hasValue, isTrue);
    expect(refreshingState.requireValue, <Quote>[createQuote()]);
    expect(refreshCompleted, isFalse);

    secondRequest.complete(<Quote>[createQuote(id: 2, author: 'Reviewer')]);
    await refreshFuture;

    expect(subscription.read().hasValue, isTrue);
    expect(subscription.read().hasError, isFalse);
    expect(subscription.read().requireValue, <Quote>[
      createQuote(id: 2, author: 'Reviewer'),
    ]);
  });
}

class _QueuedQuotesRepository implements QuotesRepository {
  final List<Completer<List<Quote>>> _requests = <Completer<List<Quote>>>[];

  void enqueue(Completer<List<Quote>> request) {
    _requests.add(request);
  }

  @override
  Future<List<Quote>> fetchQuotes({required int limit, required int skip}) {
    if (_requests.isEmpty) {
      throw StateError('No queued quotes request configured');
    }

    return _requests.removeAt(0).future;
  }
}
