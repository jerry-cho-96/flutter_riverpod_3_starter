import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/product_detail_controller.dart';
import '../../application/providers/product_detail_argument_provider.dart';
import '../../domain/entities/product.dart';

mixin class ProductDetailPresentationStateMixin {
  int watchProductId(WidgetRef ref) {
    return ref.watch(productDetailArgumentProvider);
  }

  AsyncValue<Product> watchProductDetail(WidgetRef ref) {
    return ref.watch(productDetailControllerProvider);
  }
}

mixin class ProductDetailPresentationEventMixin {
  Future<void> refreshProductDetail(WidgetRef ref) {
    return ref.read(productDetailControllerProvider.notifier).refresh();
  }

  Future<void> showResolvedProductSummary(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final product = await ref.read(productDetailControllerProvider.future);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${product.title} · \$${product.price.toStringAsFixed(2)} · 재고 ${product.stock}',
        ),
      ),
    );
  }
}
