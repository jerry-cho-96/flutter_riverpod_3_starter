import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';

final persistSessionUseCaseProvider = Provider<PersistSessionUseCase>((ref) {
  return PersistSessionUseCase(ref.watch(tokenStorageProvider));
});

class PersistSessionUseCase {
  const PersistSessionUseCase(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> call(AuthSession session) async {
    await _tokenStorage.save(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );
  }
}
