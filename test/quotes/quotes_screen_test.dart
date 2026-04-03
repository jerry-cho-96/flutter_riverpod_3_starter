import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/features/quotes/domain/entities/quote.dart';
import 'package:riverpod_origin_template/features/quotes/presentation/quotes_screen.dart';
import 'package:riverpod_origin_template/features/quotes/quotes_providers.dart';

import '../helpers/test_doubles.dart';

void main() {
  testWidgets('명언 화면은 명언 목록과 작성자를 렌더링한다', (tester) async {
    final repository = FakeQuotesRepository()
      ..fetchQuotesResult = <Quote>[
        createQuote(quote: 'Stay curious.', author: 'Explorer'),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [quotesRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: QuotesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('명언 모음'), findsOneWidget);
    expect(find.textContaining('Stay curious.'), findsOneWidget);
    expect(find.text('Explorer'), findsOneWidget);
  });
}
