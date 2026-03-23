enum AppEnvironment {
  development('dev'),
  staging('staging'),
  production('prod');

  const AppEnvironment(this.value);

  final String value;

  static AppEnvironment fromValue(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.value == value,
      orElse: () => AppEnvironment.development,
    );
  }
}
