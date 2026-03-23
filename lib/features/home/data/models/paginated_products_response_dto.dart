import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_dto.dart';

part 'paginated_products_response_dto.freezed.dart';
part 'paginated_products_response_dto.g.dart';

@freezed
abstract class PaginatedProductsResponseDto
    with _$PaginatedProductsResponseDto {
  const factory PaginatedProductsResponseDto({
    required List<ProductDto> products,
    required int total,
    required int skip,
    required int limit,
  }) = _PaginatedProductsResponseDto;

  factory PaginatedProductsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaginatedProductsResponseDtoFromJson(json);
}
