// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductsController)
const productsControllerProvider = ProductsControllerProvider._();

final class ProductsControllerProvider
    extends
        $AsyncNotifierProvider<
          ProductsController,
          PaginatedListState<Product>
        > {
  const ProductsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsControllerHash();

  @$internal
  @override
  ProductsController create() => ProductsController();
}

String _$productsControllerHash() =>
    r'a6e9fce35a4314fb8e8b9946daa7c8bef72c7f61';

abstract class _$ProductsController
    extends $AsyncNotifier<PaginatedListState<Product>> {
  FutureOr<PaginatedListState<Product>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedListState<Product>>,
              PaginatedListState<Product>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedListState<Product>>,
                PaginatedListState<Product>
              >,
              AsyncValue<PaginatedListState<Product>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
