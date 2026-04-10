import '../errors/app_failure.dart';

class PaginatedListState<T> {
  const PaginatedListState({
    required this.items,
    required this.pageSize,
    required this.totalCount,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  factory PaginatedListState.initial({
    required List<T> items,
    required int pageSize,
    required int totalCount,
  }) {
    return PaginatedListState<T>(
      items: items,
      pageSize: pageSize,
      totalCount: totalCount,
    );
  }

  final List<T> items;
  final int pageSize;
  final int totalCount;
  final bool isLoadingMore;
  final AppFailure? loadMoreFailure;

  bool get hasMore => items.length < totalCount;

  int get nextOffset => items.length;

  PaginatedListState<T> beginLoadMore() {
    return PaginatedListState<T>(
      items: items,
      pageSize: pageSize,
      totalCount: totalCount,
      isLoadingMore: true,
    );
  }

  PaginatedListState<T> appendPage(
    List<T> nextItems, {
    required int totalCount,
  }) {
    return PaginatedListState<T>(
      items: <T>[...items, ...nextItems],
      pageSize: pageSize,
      totalCount: totalCount,
    );
  }

  PaginatedListState<T> failLoadMore(AppFailure failure) {
    return PaginatedListState<T>(
      items: items,
      pageSize: pageSize,
      totalCount: totalCount,
      loadMoreFailure: failure,
    );
  }
}
