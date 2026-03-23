import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage.dart';

class SharedPreferencesTokenStorage implements TokenStorage {
  SharedPreferencesTokenStorage(this._preferences);

  final SharedPreferencesAsync _preferences;

  @override
  Future<void> clear() async {
    await _preferences.remove(accessTokenStorageKey);
    await _preferences.remove(refreshTokenStorageKey);
  }

  @override
  Future<String?> readAccessToken() async {
    return _preferences.getString(accessTokenStorageKey);
  }

  @override
  Future<String?> readRefreshToken() async {
    return _preferences.getString(refreshTokenStorageKey);
  }

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _preferences.setString(accessTokenStorageKey, accessToken);
    await _preferences.setString(refreshTokenStorageKey, refreshToken);
  }
}
