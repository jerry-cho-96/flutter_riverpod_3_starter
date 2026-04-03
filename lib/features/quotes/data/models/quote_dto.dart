import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote_dto.freezed.dart';
part 'quote_dto.g.dart';

@freezed
abstract class QuoteDto with _$QuoteDto {
  const factory QuoteDto({
    required int id,
    required String quote,
    required String author,
  }) = _QuoteDto;

  factory QuoteDto.fromJson(Map<String, dynamic> json) =>
      _$QuoteDtoFromJson(json);
}
