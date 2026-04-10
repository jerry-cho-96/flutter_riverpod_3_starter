import '../../../../core/pagination/page_chunk.dart';
import '../entities/product.dart';

abstract interface class ProductsRepository {
  Future<PageChunk<Product>> fetchProducts({
    required int limit,
    required int skip,
  });

  Future<Product> fetchProductDetail({required int productId});
}
