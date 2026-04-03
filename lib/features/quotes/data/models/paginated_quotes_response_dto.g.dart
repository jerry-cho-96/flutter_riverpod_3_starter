// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_quotes_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedQuotesResponseDto _$PaginatedQuotesResponseDtoFromJson(
  Map<String, dynamic> json,
) => _PaginatedQuotesResponseDto(
  quotes: (json['quotes'] as List<dynamic>)
      .map((e) => QuoteDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  skip: (json['skip'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedQuotesResponseDtoToJson(
  _PaginatedQuotesResponseDto instance,
) => <String, dynamic>{
  'quotes': instance.quotes,
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
