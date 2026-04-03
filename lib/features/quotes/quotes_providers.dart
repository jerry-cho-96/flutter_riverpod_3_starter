import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/quotes_remote_data_source.dart';
import 'data/repositories/quotes_repository_impl.dart';
import 'domain/repositories/quotes_repository.dart';

/// Quotes feature 공개 DI 진입점. repository wiring 만 담당한다.
final quotesRepositoryProvider = Provider<QuotesRepository>((ref) {
  return QuotesRepositoryImpl(ref.watch(quotesRemoteDataSourceProvider));
});
