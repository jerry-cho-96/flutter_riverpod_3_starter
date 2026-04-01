import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/application/session_state.dart';
import '../../auth/domain/entities/app_user.dart';
import '../application/products_provider.dart';
import '../domain/entities/product.dart';

mixin class HomePresentationStateMixin {
  AsyncValue<List<Product>> watchProducts(WidgetRef ref) {
    return ref.watch(productsControllerProvider);
  }

  AppUser? watchCurrentUser(WidgetRef ref) {
    final sessionState = ref.watch(sessionControllerProvider);
    return switch (sessionState) {
      SessionAuthenticated(:final session) => session.user,
      _ => null,
    };
  }

  AppConfig watchAppConfig(WidgetRef ref) {
    return ref.watch(appConfigProvider);
  }
}

mixin class HomePresentationEventMixin {
  Future<void> refreshProducts(WidgetRef ref) {
    return ref.read(productsControllerProvider.notifier).refresh();
  }
}
