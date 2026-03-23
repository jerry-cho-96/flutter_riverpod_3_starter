import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppMonitoring {
  void recordBreadcrumb(String message);

  void recordError(
    String reason, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  });
}

class DebugAppMonitoring implements AppMonitoring {
  const DebugAppMonitoring();

  @override
  void recordBreadcrumb(String message) {
    if (kDebugMode) {
      debugPrint('[MONITORING][BREADCRUMB] $message');
    }
  }

  @override
  void recordError(
    String reason, {
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    debugPrint('[MONITORING][${fatal ? 'FATAL' : 'ERROR'}] $reason');
    if (error != null && kDebugMode) {
      debugPrint('  error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('$stackTrace');
    }
  }
}

final appMonitoringProvider = Provider<AppMonitoring>((ref) {
  return const DebugAppMonitoring();
});
