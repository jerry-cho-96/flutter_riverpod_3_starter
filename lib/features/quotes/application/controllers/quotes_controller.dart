import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/pagination/paginated_list_state.dart';
import '../../domain/entities/quote.dart';
import '../usecases/get_quotes_use_case.dart';

part 'quotes_controller.g.dart';

@riverpod
class QuotesController extends _$QuotesController {
  static const int _pageSize = 20;

  @override
  Future<PaginatedListState<Quote>> build() {
    return _load(skip: 0);
  }

  Future<void> refresh() async {
    ref.read(getQuotesUseCaseProvider).clearCache();
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final currentState = state.asData?.value;
    if (currentState == null ||
        state.isLoading ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.beginLoadMore());
    final result = await ref
        .read(getQuotesUseCaseProvider)
        .call(limit: _pageSize, skip: currentState.nextOffset);

    if (!ref.mounted) {
      return;
    }

    state = result.when(
      success: (page) => AsyncData(
        currentState.appendPage(page.items, totalCount: page.total),
      ),
      failure: (error) => AsyncData(currentState.failLoadMore(error)),
    );
  }

  Future<PaginatedListState<Quote>> _load({required int skip}) async {
    final result = await ref
        .read(getQuotesUseCaseProvider)
        .call(limit: _pageSize, skip: skip);

    return result.when(
      success: (page) => PaginatedListState<Quote>.initial(
        items: page.items,
        pageSize: _pageSize,
        totalCount: page.total,
      ),
      failure: (error) => throw error,
    );
  }
}
