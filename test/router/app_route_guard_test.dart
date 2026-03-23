import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/app/router/app_route_guard.dart';
import 'package:riverpod_origin_template/app/router/app_routes.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/features/auth/application/session_state.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('AppRouteGuard', () {
    test('unknown 상태에서는 splash 로 이동하면서 원래 경로를 보존한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: const SessionState.unknown(),
        uri: Uri.parse('/home?tab=all'),
      );

      expect(
        redirect,
        AppRoute.splash.location(
          queryParameters: <String, String>{'from': '/home?tab=all'},
        ),
      );
    });

    test('unauthenticated 상태에서 보호 경로 접근 시 login 으로 리다이렉트한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: const SessionState.unauthenticated(),
        uri: Uri.parse('/home?tab=all'),
      );

      expect(
        redirect,
        AppRoute.login.location(
          queryParameters: <String, String>{'from': '/home?tab=all'},
        ),
      );
    });

    test('authenticated 상태에서 login 접근 시 from 경로로 복귀한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: SessionState.authenticated(session: createSession()),
        uri: Uri.parse('/login?from=%2Fhome%3Ftab%3Dall'),
      );

      expect(redirect, '/home?tab=all');
    });

    test('authenticated 상태에서 splash 접근 시 home 으로 이동한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: SessionState.authenticated(session: createSession()),
        uri: Uri.parse('/splash'),
      );

      expect(redirect, AppRoute.home.path);
    });

    test('restorationFailed 상태에서는 splash 로 유지한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: const SessionState.restorationFailed(
          failure: AppFailure(message: 'network', type: FailureType.network),
        ),
        uri: Uri.parse('/home'),
      );

      expect(
        redirect,
        AppRoute.splash.location(
          queryParameters: const <String, String>{'from': '/home'},
        ),
      );
    });

    test('unauthenticated 상태에서 login 접근은 허용한다', () {
      final redirect = AppRouteGuard.redirect(
        sessionState: const SessionState.unauthenticated(),
        uri: Uri.parse('/login'),
      );

      expect(redirect, isNull);
    });
  });
}
