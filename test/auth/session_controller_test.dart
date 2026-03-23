import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/core/storage/token_storage.dart';
import 'package:riverpod_origin_template/features/auth/auth_providers.dart';
import 'package:riverpod_origin_template/features/auth/application/session_controller.dart';
import 'package:riverpod_origin_template/features/auth/application/session_state.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('SessionController', () {
    test('저장된 토큰이 없으면 unauthenticated 상태가 된다', () async {
      final repository = FakeAuthRepository();
      final storage = FakeTokenStorage();
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();

      expect(
        container.read(sessionControllerProvider),
        const SessionState.unauthenticated(),
      );
      expect(storage.clearCallCount, 0);
    });

    test('저장된 토큰이 유효하면 authenticated 상태가 된다', () async {
      final storedTokens = createTokens();
      final user = createUser();
      final repository = FakeAuthRepository()..enqueueCurrentUserResult(user);
      final storage = FakeTokenStorage(storedTokens);
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();

      expect(
        container.read(sessionControllerProvider),
        SessionState.authenticated(
          session: createSession(tokens: storedTokens, user: user),
        ),
      );
    });

    test('auth/me 실패 후 refresh 성공 시 새 토큰으로 복구한다', () async {
      final expiredTokens = createTokens(
        accessToken: 'expired-access',
        refreshToken: 'refresh-1',
      );
      final refreshedTokens = createTokens(
        accessToken: 'fresh-access',
        refreshToken: 'refresh-2',
      );
      final user = createUser();
      final repository = FakeAuthRepository()
        ..enqueueCurrentUserResult(
          const AppException('token expired', statusCode: 401),
        )
        ..refreshResult = refreshedTokens
        ..enqueueCurrentUserResult(user);
      final storage = FakeTokenStorage(expiredTokens);
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();

      expect(repository.refreshCallCount, 1);
      expect(storage.storedTokens, refreshedTokens);
      expect(
        container.read(sessionControllerProvider),
        SessionState.authenticated(
          session: createSession(tokens: refreshedTokens, user: user),
        ),
      );
    });

    test('refresh 까지 실패하면 토큰을 비우고 unauthenticated 상태가 된다', () async {
      final expiredTokens = createTokens(
        accessToken: 'expired-access',
        refreshToken: 'refresh-1',
      );
      final repository = FakeAuthRepository()
        ..enqueueCurrentUserResult(
          const AppException('token expired', statusCode: 401),
        )
        ..refreshResult = const AppException('refresh failed', statusCode: 401);
      final storage = FakeTokenStorage(expiredTokens);
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();

      expect(
        container.read(sessionControllerProvider),
        const SessionState.unauthenticated(),
      );
      expect(storage.storedTokens, isNull);
      expect(storage.clearCallCount, 1);
    });

    test('네트워크 오류면 토큰을 유지하고 restorationFailed 상태가 된다', () async {
      final storedTokens = createTokens();
      final repository = FakeAuthRepository()
        ..enqueueCurrentUserResult(const AppException('network error'));
      final storage = FakeTokenStorage(storedTokens);
      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);

      await container.read(sessionControllerProvider.notifier).restoreSession();

      expect(
        container.read(sessionControllerProvider),
        const SessionState.restorationFailed(
          failure: AppFailure(
            message: 'network error',
            type: FailureType.network,
          ),
        ),
      );
      expect(storage.storedTokens, storedTokens);
      expect(storage.clearCallCount, 0);
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
