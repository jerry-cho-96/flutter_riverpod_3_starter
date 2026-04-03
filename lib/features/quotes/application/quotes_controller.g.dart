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
    extends $AsyncNotifierProvider<QuotesController, List<Quote>> {
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

String _$quotesControllerHash() => r'84f81dd02ca7ca7003b00a3c6ef2a8ae7ccb8066';

abstract class _$QuotesController extends $AsyncNotifier<List<Quote>> {
  FutureOr<List<Quote>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Quote>>, List<Quote>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Quote>>, List<Quote>>,
              AsyncValue<List<Quote>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
