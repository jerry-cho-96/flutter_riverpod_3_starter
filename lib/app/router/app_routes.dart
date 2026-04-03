enum AppRoute {
  splash(name: 'splash', path: '/splash'),
  login(name: 'login', path: '/login'),
  home(name: 'home', path: '/home'),
  quotes(name: 'quotes', path: '/quotes'),
  todos(name: 'todos', path: '/todos'),
  productDetail(name: 'productDetail', path: '/home/products/:productId');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;

  String location({
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    var resolvedPath = path;
    for (final entry in pathParameters.entries) {
      resolvedPath = resolvedPath.replaceAll(':${entry.key}', entry.value);
    }

    return Uri(
      path: resolvedPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}
