import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../auth_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/auth_tokens.dart';

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

sealed class RestoreSessionOutcome {
  const RestoreSessionOutcome();
}

final class RestoreSessionAuthenticated extends RestoreSessionOutcome {
  const RestoreSessionAuthenticated(this.session);

  final AuthSession session;
}

final class RestoreSessionUnauthenticated extends RestoreSessionOutcome {
  const RestoreSessionUnauthenticated();
}

final class RestoreSessionFailure extends RestoreSessionOutcome {
  const RestoreSessionFailure(this.failure);

  final AppFailure failure;
}

class RestoreSessionUseCase {
  const RestoreSessionUseCase({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  }) : _authRepository = authRepository,
       _tokenStorage = tokenStorage;

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  Future<RestoreSessionOutcome> call() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (accessToken == null || refreshToken == null) {
      return const RestoreSessionUnauthenticated();
    }
    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    try {
      final user = await _authRepository.fetchCurrentUser();
      return RestoreSessionAuthenticated(
        AuthSession(user: user, tokens: tokens),
      );
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return _restoreWithRefresh(tokens);
      }

      return RestoreSessionFailure(AppFailure.fromAppException(error));
    } catch (error) {
      return RestoreSessionFailure(
        AppFailure.fromObject(
          error,
          fallbackMessage: '세션을 복구하지 못했습니다. 네트워크를 확인한 뒤 다시 시도해 주세요.',
        ),
      );
    }
  }

  Future<RestoreSessionOutcome> _restoreWithRefresh(AuthTokens tokens) async {
    try {
      final refreshedTokens = await _authRepository.refreshSession(
        refreshToken: tokens.refreshToken,
      );
      await _tokenStorage.save(
        accessToken: refreshedTokens.accessToken,
        refreshToken: refreshedTokens.refreshToken,
      );
      final user = await _authRepository.fetchCurrentUser();

      return RestoreSessionAuthenticated(
        AuthSession(user: user, tokens: refreshedTokens),
      );
    } on AppException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _tokenStorage.clear();
        return const RestoreSessionUnauthenticated();
      }

      return RestoreSessionFailure(AppFailure.fromAppException(error));
    } catch (error) {
      return RestoreSessionFailure(
        AppFailure.fromObject(
          error,
          fallbackMessage: '세션을 복구하지 못했습니다. 네트워크를 확인한 뒤 다시 시도해 주세요.',
        ),
      );
    }
  }
}
