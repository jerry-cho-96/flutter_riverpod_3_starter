import 'package:freezed_annotation/freezed_annotation.dart';

part 'quote.freezed.dart';

@freezed
abstract class Quote with _$Quote {
  const factory Quote({
    required int id,
    required String quote,
    required String author,
  }) = _Quote;
}
