import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
    required double rating,
    required int stock,
    String? brand,
    String? thumbnail,
  }) = _Product;
}
