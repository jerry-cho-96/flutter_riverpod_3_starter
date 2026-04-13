import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/storage/token_storage.dart';
import 'package:riverpod_origin_template/features/auth/auth_providers.dart';
import 'package:riverpod_origin_template/features/auth/application/controllers/session_controller.dart';
import 'package:riverpod_origin_template/features/auth/application/controllers/sign_in_controller.dart';
import 'package:riverpod_origin_template/features/auth/application/states/session_state.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('SignInController', () {
    test('로그인 성공 시 세션이 저장되고 authenticated 상태가 된다', () async {
      final session = createSession();
      final repository = FakeAuthRepository()..signInResult = session;
      final storage = FakeTokenStorage();
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();
      await container
          .read(signInControllerProvider.notifier)
          .signIn(username: 'emilys', password: 'emilyspass');

      expect(container.read(signInControllerProvider).hasError, isFalse);
      expect(storage.storedTokens, session.tokens);
      expect(
        container.read(sessionControllerProvider),
        SessionState.authenticated(session: session),
      );
    });

    test('로그인 실패 시 에러를 유지하고 인증 상태를 바꾸지 않는다', () async {
      final repository = FakeAuthRepository()
        ..signInResult = const AppException(
          'Invalid credentials',
          statusCode: 400,
        );
      final storage = FakeTokenStorage();
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();
      await container
          .read(signInControllerProvider.notifier)
          .signIn(username: 'emilys', password: 'wrong-password');

      expect(container.read(signInControllerProvider).hasError, isTrue);
      expect(
        container.read(sessionControllerProvider),
        const SessionState.unauthenticated(),
      );
    });
  });
}

ProviderContainer _createContainer({
  required FakeAuthRepository repository,
  required FakeTokenStorage storage,
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}
