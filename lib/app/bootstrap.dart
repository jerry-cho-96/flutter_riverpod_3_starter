import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import '../core/config/app_config.dart';
import '../core/config/app_flavors.dart';
import '../core/logging/app_logger.dart';
import '../core/logging/app_monitoring.dart';
import '../core/logging/app_provider_observer.dart';
import 'app.dart';

void bootstrap({
  AppFlavor? flavor,
  AppLogger? logger,
  AppMonitoring? monitoring,
}) {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  final resolvedLogger = logger ?? const DebugAppLogger();
  final resolvedMonitoring = monitoring ?? DebugAppMonitoring();
  final config = AppConfig.fromEnvironment(
    fallbackApiBaseUrl: flavor?.apiBaseUrl,
    environmentOverride: flavor?.environment,
  );

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    resolvedLogger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    resolvedMonitoring.recordError(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
      fatal: false,
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    resolvedLogger.error(
      'Uncaught platform error',
      error: error,
      stackTrace: stackTrace,
    );
    resolvedMonitoring.recordError(
      'Uncaught platform error',
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
    return true;
  };

  resolvedMonitoring.recordBreadcrumb(
    'bootstrap environment=${config.environment.value}',
  );

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        appLoggerProvider.overrideWithValue(resolvedLogger),
        appMonitoringProvider.overrideWithValue(resolvedMonitoring),
      ],
      observers: <ProviderObserver>[
        AppProviderObserver(resolvedLogger, resolvedMonitoring),
      ],
      child: const App(),
    ),
  );
}
