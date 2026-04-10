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
  DebugAppMonitoring({this.maxBreadcrumbs = 20});

  final int maxBreadcrumbs;
  final List<String> _breadcrumbs = <String>[];

  @visibleForTesting
  List<String> get breadcrumbs => List<String>.unmodifiable(_breadcrumbs);

  @override
  void recordBreadcrumb(String message) {
    final entry = '[${DateTime.now().toIso8601String()}] $message';
    _breadcrumbs.add(entry);
    if (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }

    if (kDebugMode) {
      debugPrint('[MONITORING][BREADCRUMB] $entry');
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
    if (_breadcrumbs.isNotEmpty && kDebugMode) {
      debugPrint('[MONITORING][RECENT_BREADCRUMBS]');
      for (final breadcrumb in _breadcrumbs) {
        debugPrint('  $breadcrumb');
      }
    }
    if (error != null && kDebugMode) {
      debugPrint('  error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('$stackTrace');
    }
  }
}

final appMonitoringProvider = Provider<AppMonitoring>((ref) {
  return DebugAppMonitoring();
});
