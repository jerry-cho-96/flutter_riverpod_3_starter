import '../../features/auth/application/states/session_state.dart';
import 'app_routes.dart';

class AppRouteGuard {
  const AppRouteGuard._();

  static String? redirect({
    required SessionState sessionState,
    required Uri uri,
  }) {
    final currentPath = uri.path.isEmpty ? AppRoute.splash.path : uri.path;
    final isSplash = currentPath == AppRoute.splash.path;
    final isLogin = currentPath == AppRoute.login.path;

    return switch (sessionState) {
      SessionUnknown() =>
        isSplash
            ? null
            : AppRoute.splash.location(
                queryParameters: <String, String>{'from': uri.toString()},
              ),
      SessionRestorationFailed() =>
        isSplash
            ? null
            : AppRoute.splash.location(
                queryParameters: <String, String>{'from': uri.toString()},
              ),
      SessionUnauthenticated() => _redirectUnauthenticated(
        uri: uri,
        isSplash: isSplash,
        isLogin: isLogin,
      ),
      SessionAuthenticated() =>
        (isSplash || isLogin)
            ? _sanitizeReturnLocation(uri.queryParameters['from'])
            : null,
    };
  }

  static String? _redirectUnauthenticated({
    required Uri uri,
    required bool isSplash,
    required bool isLogin,
  }) {
    if (isLogin) {
      return null;
    }

    if (isSplash) {
      final from = uri.queryParameters['from'];
      if (from == null || from.isEmpty) {
        return AppRoute.login.path;
      }

      return AppRoute.login.location(
        queryParameters: <String, String>{'from': from},
      );
    }

    return AppRoute.login.location(
      queryParameters: <String, String>{'from': uri.toString()},
    );
  }

  static String _sanitizeReturnLocation(String? location) {
    if (location == null || location.isEmpty) {
      return AppRoute.home.path;
    }

    final uri = Uri.tryParse(location);
    if (uri == null) {
      return AppRoute.home.path;
    }

    final path = uri.path;
    if (path.isEmpty ||
        path == AppRoute.splash.path ||
        path == AppRoute.login.path) {
      return AppRoute.home.path;
    }

    return uri.toString();
  }
}
