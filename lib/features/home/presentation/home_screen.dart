import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/config/template_example.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/async_value_view.dart';
import '../../auth/domain/entities/app_user.dart';
import '../domain/entities/product.dart';
import '../application/products_state.dart';
import 'home_presentation_mixins.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with HomePresentationStateMixin, HomePresentationEventMixin {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = watchProducts(ref);
    final config = watchAppConfig(ref);
    final user = watchCurrentUser(ref);
    final productsState = productsAsync.asData?.value;
    final isInitialLoading = productsAsync.isLoading && productsState == null;
    final isSearchBusy =
        isInitialLoading ||
        (productsState?.isRefreshing ?? false) ||
        (productsState?.isSearching ?? false);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pagination + Search Dry Run',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '읽기 전용 feature 에 검색과 페이지 누적 로딩을 추가해도 계층 구조가 유지되는지 검증합니다.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    enabled: !isSearchBusy,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: '상품 검색',
                      hintText: '예: phone',
                      suffixIcon: _searchController.text.trim().isEmpty
                          ? null
                          : IconButton(
                              onPressed: isSearchBusy ? null : _clearSearch,
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submitSearch(),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: isSearchBusy ? null : _submitSearch,
                        icon: isSearchBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search_rounded),
                        label: Text(
                          (productsState?.isSearching ?? false)
                              ? '검색 중...'
                              : (productsState?.isRefreshing ?? false)
                              ? '새로고침 중...'
                              : '검색 적용',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: isSearchBusy ? null : _clearSearch,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('검색 초기화'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AsyncValueView<ProductsState>(
            value: productsAsync,
            onRetry: () {
              _refreshProducts();
            },
            data: (productsState) {
              final products = productsState.products;
              if (products.isEmpty) {
                return _EmptyProductsCard(query: productsState.query);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          productsState.query.isEmpty
                              ? '전체 상품 ${productsState.total}개'
                              : '"${productsState.query}" 검색 결과 ${productsState.total}개',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${products.length}/${productsState.total}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  _LoadMoreSection(state: productsState, onLoadMore: _loadMore),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearSearch() async {
    if (_searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    setState(() {});
    await _submitSearch();
  }

  Future<void> _loadMore() async {
    try {
      await loadMoreProducts(ref);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    }
  }

  Future<void> _refreshProducts() async {
    try {
      await refreshProducts(ref);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    }
  }

  Future<void> _submitSearch() async {
    try {
      await searchProducts(ref, _searchController.text);
      if (!mounted) {
        return;
      }
      FocusScope.of(context).unfocus();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    }
  }

  void _showError(Object error) {
    final message = error is AppFailure ? error.message : '상품 목록을 불러오지 못했습니다.';
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
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

class _EmptyProductsCard extends StatelessWidget {
  const _EmptyProductsCard({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = query.isEmpty ? '표시할 상품이 없습니다.' : '"$query" 검색 결과가 없습니다.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(message, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '검색어를 바꾸거나 초기화한 뒤 다시 시도해 보세요.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreSection extends StatelessWidget {
  const _LoadMoreSection({required this.state, required this.onLoadMore});

  final ProductsState state;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!state.hasMore) {
      return Text(
        '마지막 페이지입니다.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium,
      );
    }

    return FilledButton.icon(
      onPressed: state.isLoadingMore ? null : onLoadMore,
      icon: state.isLoadingMore
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.expand_more_rounded),
      label: Text(state.isLoadingMore ? '불러오는 중...' : '상품 더 보기'),
    );
  }
}
