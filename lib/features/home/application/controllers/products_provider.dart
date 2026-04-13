import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/pagination/paginated_list_state.dart';
import '../../domain/entities/product.dart';
import '../usecases/get_products_use_case.dart';

part 'products_provider.g.dart';

@riverpod
class ProductsController extends _$ProductsController {
  static const int _pageSize = 20;

  @override
  Future<PaginatedListState<Product>> build() {
    return _load(skip: 0);
  }

  Future<void> refresh() async {
    ref.read(getProductsUseCaseProvider).clearCache();
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
        .read(getProductsUseCaseProvider)
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

  Future<PaginatedListState<Product>> _load({required int skip}) async {
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(limit: _pageSize, skip: skip);

    return result.when(
      success: (page) => PaginatedListState<Product>.initial(
        items: page.items,
        pageSize: _pageSize,
        totalCount: page.total,
      ),
      failure: (error) => throw error,
    );
  }
}
