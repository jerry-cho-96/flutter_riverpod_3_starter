import 'package:freezed_annotation/freezed_annotation.dart';

import 'quote_dto.dart';

part 'paginated_quotes_response_dto.freezed.dart';
part 'paginated_quotes_response_dto.g.dart';

@freezed
abstract class PaginatedQuotesResponseDto with _$PaginatedQuotesResponseDto {
  const factory PaginatedQuotesResponseDto({
    required List<QuoteDto> quotes,
    required int total,
    required int skip,
    required int limit,
  }) = _PaginatedQuotesResponseDto;

  factory PaginatedQuotesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PaginatedQuotesResponseDtoFromJson(json);
}
