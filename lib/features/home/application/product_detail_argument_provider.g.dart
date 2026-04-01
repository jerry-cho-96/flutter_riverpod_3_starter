// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_argument_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(productDetailArgument)
const productDetailArgumentProvider = ProductDetailArgumentProvider._();

final class ProductDetailArgumentProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const ProductDetailArgumentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productDetailArgumentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productDetailArgumentHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return productDetailArgument(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$productDetailArgumentHash() =>
    r'40ef730393d5ba2ff554500b4c23c8e1734139f8';
