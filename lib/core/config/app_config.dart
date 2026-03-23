import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_environment.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.environment});

  static const String defaultApiBaseUrl = 'https://dummyjson.com';
  static const String defaultEnvironment = 'dev';

  factory AppConfig.fromEnvironment({
    String? fallbackApiBaseUrl,
    AppEnvironment? environmentOverride,
  }) {
    return AppConfig(
      apiBaseUrl:
          const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: '',
          ).trim().isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : fallbackApiBaseUrl ?? defaultApiBaseUrl,
      environment:
          environmentOverride ??
          AppEnvironment.fromValue(
            const String.fromEnvironment(
              'APP_ENV',
              defaultValue: defaultEnvironment,
            ),
          ),
    );
  }

  final String apiBaseUrl;
  final AppEnvironment environment;

  String get appName => switch (environment) {
    AppEnvironment.development => 'Riverpod Origin Template Dev',
    AppEnvironment.staging => 'Riverpod Origin Template Staging',
    AppEnvironment.production => 'Riverpod Origin Template',
  };
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
