import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_token_storage.dart';
import 'shared_preferences_token_storage.dart';

const String accessTokenStorageKey = 'auth_access_token';
const String refreshTokenStorageKey = 'auth_refresh_token';

abstract interface class TokenStorage {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> clear();
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  if (kIsWeb) {
    return SharedPreferencesTokenStorage(SharedPreferencesAsync());
  }

  return SecureTokenStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );
});
