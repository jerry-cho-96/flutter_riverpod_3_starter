import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';
import 'app_monitoring.dart';

final class AppProviderObserver extends ProviderObserver {
  AppProviderObserver(this._logger, this._monitoring);

  final AppLogger _logger;
  final AppMonitoring _monitoring;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    _logger.debug(
      'provider updated: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final providerName = context.provider.name ?? context.provider.runtimeType;
    _logger.error(
      'provider failed: $providerName',
      error: error,
      stackTrace: stackTrace,
    );
    _monitoring.recordError(
      'provider failed: $providerName',
      error: error,
      stackTrace: stackTrace,
      fatal: false,
    );
  }
}
