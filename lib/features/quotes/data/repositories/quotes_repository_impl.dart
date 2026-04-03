import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../datasources/quotes_remote_data_source.dart';
import '../models/quote_dto.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  QuotesRepositoryImpl(this._remoteDataSource);

  final QuotesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Quote>> fetchQuotes({
    required int limit,
    required int skip,
  }) async {
    final response = await _remoteDataSource.fetchQuotes(
      limit: limit,
      skip: skip,
    );

    return response.quotes.map(_mapQuote).toList(growable: false);
  }

  Quote _mapQuote(QuoteDto dto) {
    return Quote(id: dto.id, quote: dto.quote, author: dto.author);
  }
}
