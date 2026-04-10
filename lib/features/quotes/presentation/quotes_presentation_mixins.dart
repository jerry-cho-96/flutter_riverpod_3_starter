import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/pagination/paginated_list_state.dart';
import '../application/quotes_controller.dart';
import '../domain/entities/quote.dart';

mixin class QuotesPresentationStateMixin {
  AsyncValue<PaginatedListState<Quote>> watchQuotes(WidgetRef ref) {
    return ref.watch(quotesControllerProvider);
  }
}

mixin class QuotesPresentationEventMixin {
  Future<void> refreshQuotes(WidgetRef ref) {
    return ref.read(quotesControllerProvider.notifier).refresh();
  }

  Future<void> loadMoreQuotes(WidgetRef ref) {
    return ref.read(quotesControllerProvider.notifier).loadMore();
  }
}
