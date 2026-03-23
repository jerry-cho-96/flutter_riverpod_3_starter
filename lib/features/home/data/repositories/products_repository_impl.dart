import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_dto.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remoteDataSource);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> fetchProducts({
    required int limit,
    required int skip,
  }) async {
    final response = await _remoteDataSource.fetchProducts(
      limit: limit,
      skip: skip,
    );

    return response.products.map(_mapProduct).toList(growable: false);
  }

  Product _mapProduct(ProductDto dto) {
    return Product(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      category: dto.category,
      price: dto.price,
      rating: dto.rating,
      stock: dto.stock,
      brand: dto.brand,
      thumbnail: dto.thumbnail,
    );
  }
}
