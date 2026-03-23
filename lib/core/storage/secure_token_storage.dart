import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_tokens.dart';
import 'token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() async {
    await _storage.delete(key: accessTokenStorageKey);
    await _storage.delete(key: refreshTokenStorageKey);
  }

  @override
  Future<AuthTokens?> read() async {
    final accessToken = await _storage.read(key: accessTokenStorageKey);
    final refreshToken = await _storage.read(key: refreshTokenStorageKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    await _storage.write(key: accessTokenStorageKey, value: tokens.accessToken);
    await _storage.write(
      key: refreshTokenStorageKey,
      value: tokens.refreshToken,
    );
  }
}
