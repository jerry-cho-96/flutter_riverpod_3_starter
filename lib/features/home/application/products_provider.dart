import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_page.dart';
import 'products_state.dart';
import 'usecases/get_products_use_case.dart';

part 'products_provider.g.dart';

@riverpod
class ProductsController extends _$ProductsController {
  static const int _pageSize = 20;

  @override
  Future<ProductsState> build() {
    return _loadFirstPage(query: '');
  }

  Future<void> refresh() async {
    final currentState = state.asData?.value;
    if (currentState == null) {
      state = const AsyncLoading<ProductsState>();
    } else {
      state = AsyncData(
        currentState.copyWith(
          isRefreshing: true,
          isSearching: false,
          isLoadingMore: false,
        ),
      );
    }

    await _replacePage(
      query: currentState?.query ?? '',
      previousState: currentState,
    );
  }

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();
    final currentState = state.asData?.value;
    if (currentState == null) {
      state = const AsyncLoading<ProductsState>();
    } else {
      state = AsyncData(
        currentState.copyWith(
          isRefreshing: false,
          isSearching: normalizedQuery != currentState.query,
          isLoadingMore: false,
        ),
      );
    }

    await _replacePage(query: normalizedQuery, previousState: currentState);
  }

  Future<void> loadMore() async {
    final currentState = state.asData?.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.isRefreshing ||
        currentState.isSearching ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = await _getProductsPage(
        query: currentState.query,
        skip: currentState.products.length,
      );
      final nextProducts = <Product>[
        ...currentState.products,
        ...nextPage.products,
      ];
      state = AsyncData(
        ProductsState(
          products: nextProducts,
          query: currentState.query,
          total: nextPage.total,
          isRefreshing: false,
          isSearching: false,
          isLoadingMore: false,
        ),
      );
    } on AppFailure {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  Future<ProductsState> _loadFirstPage({required String query}) async {
    final firstPage = await _getProductsPage(query: query, skip: 0);
    return ProductsState.fromPage(firstPage, query: query);
  }

  Future<void> _replacePage({
    required String query,
    required ProductsState? previousState,
  }) async {
    try {
      state = AsyncData(await _loadFirstPage(query: query));
    } on AppFailure {
      if (previousState != null) {
        state = AsyncData(
          previousState.copyWith(
            isRefreshing: false,
            isSearching: false,
            isLoadingMore: false,
          ),
        );
      }
      rethrow;
    }
  }

  Future<ProductPage> _getProductsPage({
    required String query,
    required int skip,
  }) async {
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(limit: _pageSize, skip: skip, query: query);

    return result.when(
      success: (productsPage) => productsPage,
      failure: (error) => throw error,
    );
  }
}
