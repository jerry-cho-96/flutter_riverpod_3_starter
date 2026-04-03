import '../entities/quote.dart';

abstract interface class QuotesRepository {
  Future<List<Quote>> fetchQuotes({required int limit, required int skip});
}
