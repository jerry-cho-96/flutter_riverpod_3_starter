// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QuotesController)
const quotesControllerProvider = QuotesControllerProvider._();

final class QuotesControllerProvider
    extends
        $AsyncNotifierProvider<QuotesController, PaginatedListState<Quote>> {
  const QuotesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quotesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quotesControllerHash();

  @$internal
  @override
  QuotesController create() => QuotesController();
}

String _$quotesControllerHash() => r'546f4a97e5f73c26887946cf7c879129829bf9ac';

abstract class _$QuotesController
    extends $AsyncNotifier<PaginatedListState<Quote>> {
  FutureOr<PaginatedListState<Quote>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedListState<Quote>>,
              PaginatedListState<Quote>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedListState<Quote>>,
                PaginatedListState<Quote>
              >,
              AsyncValue<PaginatedListState<Quote>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
