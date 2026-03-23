import 'package:shared_preferences/shared_preferences.dart';

import 'auth_tokens.dart';
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
  Future<AuthTokens?> read() async {
    final accessToken = await _preferences.getString(accessTokenStorageKey);
    final refreshToken = await _preferences.getString(refreshTokenStorageKey);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> save(AuthTokens tokens) async {
    await _preferences.setString(accessTokenStorageKey, tokens.accessToken);
    await _preferences.setString(refreshTokenStorageKey, tokens.refreshToken);
  }
}
