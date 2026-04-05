import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_dto.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remoteDataSource);

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<ProductPage> fetchProducts({
    required int limit,
    required int skip,
    String? query,
  }) async {
    final response = await _remoteDataSource.fetchProducts(
      limit: limit,
      skip: skip,
      query: query,
    );

    return ProductPage(
      products: response.products.map(_mapProduct).toList(growable: false),
      total: response.total,
      skip: response.skip,
      limit: response.limit,
    );
  }

  @override
  Future<Product> fetchProductDetail({required int productId}) async {
    final product = await _remoteDataSource.fetchProductDetail(
      productId: productId,
    );

    return _mapProduct(product);
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
