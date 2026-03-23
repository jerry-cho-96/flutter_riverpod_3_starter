// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_products_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedProductsResponseDto _$PaginatedProductsResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PaginatedProductsResponseDto(
  products: (json['products'] as List<dynamic>)
      .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedProductsResponseDtoToJson(
  _PaginatedProductsResponseDto instance,
) => <String, dynamic>{
  'products': instance.products,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
