enum AppRoute {
  splash(name: 'splash', path: '/splash'),
  login(name: 'login', path: '/login'),
  home(name: 'home', path: '/home');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;

  String location({
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    return Uri(
      path: path,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}
