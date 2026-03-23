import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppLogger {
  void debug(String message);

  void info(String message);

  void error(String message, {Object? error, StackTrace? stackTrace});
}

class DebugAppLogger implements AppLogger {
  const DebugAppLogger();

  @override
  void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  @override
  void info(String message) {
    debugPrint('[INFO] $message');
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('  error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('$stackTrace');
    }
  }
}

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const DebugAppLogger();
});
