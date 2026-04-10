import '../../../../core/pagination/page_chunk.dart';
import '../../domain/entities/quote.dart';
import '../../domain/repositories/quotes_repository.dart';
import '../datasources/quotes_remote_data_source.dart';
import '../models/quote_dto.dart';

class QuotesRepositoryImpl implements QuotesRepository {
  QuotesRepositoryImpl(this._remoteDataSource);

  final QuotesRemoteDataSource _remoteDataSource;

  @override
  Future<PageChunk<Quote>> fetchQuotes({
    required int limit,
    required int skip,
  }) async {
    final response = await _remoteDataSource.fetchQuotes(
      limit: limit,
      skip: skip,
    );

    return PageChunk<Quote>(
      items: response.quotes.map(_mapQuote).toList(growable: false),
      total: response.total,
      skip: response.skip,
      limit: response.limit,
    );
  }

  Quote _mapQuote(QuoteDto dto) {
    return Quote(id: dto.id, quote: dto.quote, author: dto.author);
  }
}
