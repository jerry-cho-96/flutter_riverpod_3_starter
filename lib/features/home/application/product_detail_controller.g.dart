// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductDetailController)
const productDetailControllerProvider = ProductDetailControllerProvider._();

final class ProductDetailControllerProvider
    extends $AsyncNotifierProvider<ProductDetailController, Product> {
  const ProductDetailControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productDetailControllerProvider',
        isAutoDispose: true,
        dependencies: const <ProviderOrFamily>[productDetailArgumentProvider],
        $allTransitiveDependencies: const <ProviderOrFamily>[
          ProductDetailControllerProvider.$allTransitiveDependencies0,
        ],
      );

  static const $allTransitiveDependencies0 = productDetailArgumentProvider;

  @override
  String debugGetCreateSourceHash() => _$productDetailControllerHash();

  @$internal
  @override
  ProductDetailController create() => ProductDetailController();
}

String _$productDetailControllerHash() =>
    r'f1016b2a986475c64db41e708f5f0e112a077d8e';

abstract class _$ProductDetailController extends $AsyncNotifier<Product> {
  FutureOr<Product> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Product>, Product>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Product>, Product>,
              AsyncValue<Product>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
