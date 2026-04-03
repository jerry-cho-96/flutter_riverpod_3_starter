import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/config/template_example.dart';
import '../../../core/presentation/async_value_view.dart';
import '../../auth/domain/entities/app_user.dart';
import '../domain/entities/product.dart';
import 'home_presentation_mixins.dart';

class HomeScreen extends ConsumerWidget
    with HomePresentationStateMixin, HomePresentationEventMixin {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = watchProducts(ref);
    final config = watchAppConfig(ref);
    final user = watchCurrentUser(ref);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => refreshProducts(ref),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          _ProfileSummary(user: user, apiBaseUrl: config.apiBaseUrl),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoute.quotes.path),
                  icon: const Icon(Icons.format_quote_rounded),
                  label: const Text('명언 feature 드라이런 열기'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push(AppRoute.todos.path),
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('할 일 mutation 드라이런 열기'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            TemplateExample.productsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            TemplateExample.productsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          AsyncValueView<List<Product>>(
            value: productsAsync,
            onRetry: () => refreshProducts(ref),
            data: (products) {
              return Column(
                children: <Widget>[
                  for (
                    var index = 0;
                    index < products.length;
                    index++
                  ) ...<Widget>[
                    _ProductCard(
                      product: products[index],
                      onTap: () {
                        context.push(
                          AppRoute.productDetail.location(
                            pathParameters: <String, String>{
                              'productId': products[index].id.toString(),
                            },
                          ),
                        );
                      },
                    ),
                    if (index != products.length - 1)
                      const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.user, required this.apiBaseUrl});

  final AppUser user;
  final String apiBaseUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: user.image != null
                  ? NetworkImage(user.image!)
                  : null,
              child: user.image == null
                  ? Text(user.firstName.characters.first)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(user.displayName, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      const Chip(
                        avatar: Icon(Icons.verified_user_rounded),
                        label: Text('Authenticated'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.api_rounded),
                        label: Text(apiBaseUrl),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: product.thumbnail != null
                      ? Image.network(
                          product.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const ColoredBox(
                              color: Color(0xFFE7ECE8),
                              child: Icon(Icons.image_not_supported_rounded),
                            );
                          },
                        )
                      : const ColoredBox(
                          color: Color(0xFFE7ECE8),
                          child: Icon(Icons.image_outlined),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(product.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Chip(label: Text(product.category)),
                        Chip(
                          label: Text('\$${product.price.toStringAsFixed(2)}'),
                        ),
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
        ),
      ),
    );
  }
}
