import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/product.dart';
import 'usecases/get_products_use_case.dart';

part 'products_provider.g.dart';

@riverpod
class ProductsController extends _$ProductsController {
  @override
  Future<List<Product>> build() {
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<List<Product>> _load() async {
    final result = await ref
        .read(getProductsUseCaseProvider)
        .call(limit: 20, skip: 0);

    return result.when(
      success: (products) => products,
      failure: (error) => throw error,
    );
  }
}
