import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/quotes_controller.dart';
import '../domain/entities/quote.dart';

mixin class QuotesPresentationStateMixin {
  AsyncValue<List<Quote>> watchQuotes(WidgetRef ref) {
    return ref.watch(quotesControllerProvider);
  }
}

mixin class QuotesPresentationEventMixin {
  Future<void> refreshQuotes(WidgetRef ref) {
    return ref.read(quotesControllerProvider.notifier).refresh();
  }
}
