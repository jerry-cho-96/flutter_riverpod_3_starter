import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  Future<String?> readAccessToken() async {
    return _storage.read(key: accessTokenStorageKey);
  }

  @override
  Future<String?> readRefreshToken() async {
    return _storage.read(key: refreshTokenStorageKey);
  }

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: accessTokenStorageKey, value: accessToken);
    await _storage.write(key: refreshTokenStorageKey, value: refreshToken);
  }
}
