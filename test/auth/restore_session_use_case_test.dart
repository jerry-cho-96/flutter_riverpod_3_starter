import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/auth/application/usecases/restore_session_use_case.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('RestoreSessionUseCase', () {
    test('저장된 토큰이 없으면 unauthenticated 를 반환한다', () async {
      final useCase = RestoreSessionUseCase(
        authRepository: FakeAuthRepository(),
        tokenStorage: FakeTokenStorage(),
      );

      final result = await useCase.call();

      expect(result, isA<RestoreSessionUnauthenticated>());
    });

    test('저장된 토큰이 유효하면 authenticated 를 반환한다', () async {
      final tokens = createTokens();
      final user = createUser();
      final repository = FakeAuthRepository()..enqueueCurrentUserResult(user);
      final storage = FakeTokenStorage(tokens);
      final useCase = RestoreSessionUseCase(
        authRepository: repository,
        tokenStorage: storage,
      );

      final result = await useCase.call();

      expect(result, isA<RestoreSessionAuthenticated>());
      final authenticated = result as RestoreSessionAuthenticated;
      expect(authenticated.session.user, user);
      expect(authenticated.session.tokens, tokens);
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
      final useCase = RestoreSessionUseCase(
        authRepository: repository,
        tokenStorage: storage,
      );

      final result = await useCase.call();

      expect(result, isA<RestoreSessionAuthenticated>());
      expect(repository.refreshCallCount, 1);
      expect(storage.storedTokens, refreshedTokens);
    });

    test('refresh 가 unauthorized 면 토큰을 비우고 unauthenticated 를 반환한다', () async {
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
      final useCase = RestoreSessionUseCase(
        authRepository: repository,
        tokenStorage: storage,
      );

      final result = await useCase.call();

      expect(result, isA<RestoreSessionUnauthenticated>());
      expect(storage.storedTokens, isNull);
      expect(storage.clearCallCount, 1);
    });

    test('네트워크 오류면 토큰을 유지하고 failure 를 반환한다', () async {
      final tokens = createTokens();
      final repository = FakeAuthRepository()
        ..enqueueCurrentUserResult(const AppException('network error'));
      final storage = FakeTokenStorage(tokens);
      final useCase = RestoreSessionUseCase(
        authRepository: repository,
        tokenStorage: storage,
      );

      final result = await useCase.call();

      expect(result, isA<RestoreSessionFailure>());
      final failure = result as RestoreSessionFailure;
      expect(
        failure.failure,
        const AppFailure(message: 'network error', type: FailureType.network),
      );
      expect(storage.storedTokens, tokens);
      expect(storage.clearCallCount, 0);
    });
  });
}
