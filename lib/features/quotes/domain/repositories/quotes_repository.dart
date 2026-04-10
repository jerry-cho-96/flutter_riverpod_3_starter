import '../../../../core/pagination/page_chunk.dart';
import '../entities/quote.dart';

abstract interface class QuotesRepository {
  Future<PageChunk<Quote>> fetchQuotes({required int limit, required int skip});
}
