import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            AsyncValueView<List<Quote>>(
              value: quotesAsync,
              loadingLabel: '명언 목록을 불러오는 중입니다...',
              onRetry: () => refreshQuotes(ref),
              data: (quotes) {
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
