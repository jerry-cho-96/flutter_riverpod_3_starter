import '../domain/entities/product.dart';
import '../domain/entities/product_page.dart';

class ProductsState {
  const ProductsState({
    required this.products,
    required this.query,
    required this.total,
    required this.isRefreshing,
    required this.isSearching,
    required this.isLoadingMore,
  });

  factory ProductsState.fromPage(ProductPage page, {required String query}) {
    return ProductsState(
      products: page.products,
      query: query,
      total: page.total,
      isRefreshing: false,
      isSearching: false,
      isLoadingMore: false,
    );
  }

  final List<Product> products;
  final String query;
  final int total;
  final bool isRefreshing;
  final bool isSearching;
  final bool isLoadingMore;

  bool get hasMore => products.length < total;

  ProductsState copyWith({
    List<Product>? products,
    String? query,
    int? total,
    bool? isRefreshing,
    bool? isSearching,
    bool? isLoadingMore,
  }) {
    return ProductsState(
      products: products ?? this.products,
      query: query ?? this.query,
      total: total ?? this.total,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
