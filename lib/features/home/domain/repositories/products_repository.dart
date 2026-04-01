import '../entities/product.dart';

abstract interface class ProductsRepository {
  Future<List<Product>> fetchProducts({required int limit, required int skip});

  Future<Product> fetchProductDetail({required int productId});
}
