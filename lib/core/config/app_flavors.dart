import 'app_config.dart';
import 'app_environment.dart';

class AppFlavor {
  const AppFlavor({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;
  final String apiBaseUrl;

  AppConfig toAppConfig() {
    return AppConfig(apiBaseUrl: apiBaseUrl, environment: environment);
  }
}

class AppFlavors {
  const AppFlavors._();

  static const AppFlavor development = AppFlavor(
    environment: AppEnvironment.development,
    apiBaseUrl: AppConfig.defaultApiBaseUrl,
  );

  static const AppFlavor staging = AppFlavor(
    environment: AppEnvironment.staging,
    apiBaseUrl: 'https://staging-api.example.com',
  );

  static const AppFlavor production = AppFlavor(
    environment: AppEnvironment.production,
    apiBaseUrl: 'https://api.example.com',
  );
}
