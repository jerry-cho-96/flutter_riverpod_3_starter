import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_list_state.dart';
import '../../../core/presentation/async_value_view.dart';
import '../domain/entities/quote.dart';
import 'quotes_presentation_mixins.dart';

class QuotesScreen extends ConsumerWidget
    with QuotesPresentationStateMixin, QuotesPresentationEventMixin {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = watchQuotes(ref);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('명언 모음')),
      body: RefreshIndicator(
        onRefresh: () => refreshQuotes(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Feature Dry Run', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '이 화면은 새 feature 추가 시 스타터킷 구조가 그대로 확장 가능한지 검증하는 예시입니다.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AsyncValueView<PaginatedListState<Quote>>(
              value: quotesAsync,
              loadingLabel: '명언 목록을 불러오는 중입니다...',
              onRetry: () => refreshQuotes(ref),
              data: (pageState) {
                final quotes = pageState.items;
                return Column(
                  children: <Widget>[
                    for (
                      var index = 0;
                      index < quotes.length;
                      index++
                    ) ...<Widget>[
                      _QuoteCard(quote: quotes[index]),
                      if (index != quotes.length - 1)
                        const SizedBox(height: 12),
                    ],
                    if (quotes.isNotEmpty) const SizedBox(height: 16),
                    _QuotesPaginationFooter(
                      pageState: pageState,
                      onLoadMore: () => loadMoreQuotes(ref),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotesPaginationFooter extends StatelessWidget {
  const _QuotesPaginationFooter({
    required this.pageState,
    required this.onLoadMore,
  });

  final PaginatedListState<Quote> pageState;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final failure = pageState.loadMoreFailure;
    if (pageState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (failure != null) {
      return Column(
        children: <Widget>[
          Text(failure.message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onLoadMore,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('명언 더 불러오기 재시도'),
          ),
        ],
      );
    }

    if (!pageState.hasMore) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: onLoadMore,
      icon: const Icon(Icons.expand_more_rounded),
      label: const Text('명언 더 보기'),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('"${quote.quote}"', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              quote.author,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
