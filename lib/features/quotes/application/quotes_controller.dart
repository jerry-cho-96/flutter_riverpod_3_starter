import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/quote.dart';
import 'usecases/get_quotes_use_case.dart';

part 'quotes_controller.g.dart';

@riverpod
class QuotesController extends _$QuotesController {
  @override
  Future<List<Quote>> build() {
    return _load();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<List<Quote>> _load() async {
    final result = await ref
        .read(getQuotesUseCaseProvider)
        .call(limit: 20, skip: 0);

    return result.when(
      success: (quotes) => quotes,
      failure: (error) => throw error,
    );
  }
}
