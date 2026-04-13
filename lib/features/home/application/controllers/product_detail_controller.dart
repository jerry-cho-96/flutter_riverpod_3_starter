import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/product.dart';
import '../providers/product_detail_argument_provider.dart';
import '../usecases/get_product_detail_use_case.dart';

part 'product_detail_controller.g.dart';

@Riverpod(dependencies: <Object>[productDetailArgument])
class ProductDetailController extends _$ProductDetailController {
  @override
  Future<Product> build() {
    final productId = ref.watch(productDetailArgumentProvider);
    return _load(productId);
  }

  Future<void> refresh() async {
    final productId = ref.read(productDetailArgumentProvider);
    ref.read(getProductDetailUseCaseProvider).clearCache(productId: productId);
    ref.invalidateSelf();
    await future;
  }

  Future<Product> _load(int productId) async {
    final result = await ref
        .read(getProductDetailUseCaseProvider)
        .call(productId: productId);

    return result.when(
      success: (product) => product,
      failure: (error) => throw error,
    );
  }
}
