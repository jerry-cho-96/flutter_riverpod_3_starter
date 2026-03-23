import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(tokenStorageProvider));
});

class SignOutUseCase {
  const SignOutUseCase(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> call() async {
    await _tokenStorage.clear();
  }
}
