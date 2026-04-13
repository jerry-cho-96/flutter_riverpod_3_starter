import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/async_value_view.dart';
import '../../application/providers/product_detail_argument_provider.dart';
import '../../domain/entities/product.dart';
import '../mixins/product_detail_presentation_mixins.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [productDetailArgumentProvider.overrideWithValue(productId)],
      child: const _ProductDetailScopeView(),
    );
  }
}

class _ProductDetailScopeView extends ConsumerWidget
    with
        ProductDetailPresentationStateMixin,
        ProductDetailPresentationEventMixin {
  const _ProductDetailScopeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = watchProductDetail(ref);

    return Scaffold(
      appBar: AppBar(title: const Text('상품 상세')),
      body: RefreshIndicator(
        onRefresh: () => refreshProductDetail(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: <Widget>[
            const _ProductScopeBadge(),
            const SizedBox(height: 16),
            AsyncValueView<Product>(
              value: detailAsync,
              loadingLabel: '상품 상세 정보를 불러오는 중입니다...',
              onRetry: () => refreshProductDetail(ref),
              data: (product) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ProductHeroCard(product: product),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            showResolvedProductSummary(context, ref),
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text('현재 정보 확인'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProductSummaryCard(product: product),
                    const SizedBox(height: 16),
                    _ProductDescriptionCard(product: product),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductScopeBadge extends ConsumerWidget
    with ProductDetailPresentationStateMixin {
  const _ProductScopeBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productId = watchProductId(ref);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        Chip(
          avatar: const Icon(Icons.route_rounded),
          label: Text('route productId=$productId'),
        ),
        const Chip(
          avatar: Icon(Icons.account_tree_outlined),
          label: Text('page-scoped argument provider'),
        ),
      ],
    );
  }
}

class _ProductHeroCard extends StatelessWidget {
  const _ProductHeroCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 16 / 9,
            child: product.thumbnail != null
                ? Image.network(
                    product.thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(
                        color: Color(0xFFE7ECE8),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                : const ColoredBox(
                    color: Color(0xFFE7ECE8),
                    child: Center(child: Icon(Icons.image_outlined, size: 40)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(product.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  product.brand ?? '브랜드 정보 없음',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Chip(label: Text(product.category)),
                    Chip(label: Text('\$${product.price.toStringAsFixed(2)}')),
                    Chip(
                      label: Text(
                        'rating ${product.rating.toStringAsFixed(1)}',
                      ),
                    ),
                    Chip(label: Text('stock ${product.stock}')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('요약', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '카테고리 ${product.category} 상품이며, 현재 가격은 \$${product.price.toStringAsFixed(2)} 입니다. '
              '평점은 ${product.rating.toStringAsFixed(1)}점이고 재고는 ${product.stock}개입니다.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDescriptionCard extends StatelessWidget {
  const _ProductDescriptionCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('설명', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(product.description, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
