import '../entities/product.dart';
import '../entities/product_page.dart';

abstract interface class ProductsRepository {
  Future<ProductPage> fetchProducts({
    required int limit,
    required int skip,
    String? query,
  });

  Future<Product> fetchProductDetail({required int productId});
}
