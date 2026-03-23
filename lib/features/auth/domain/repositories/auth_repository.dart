import '../entities/app_user.dart';
import '../entities/auth_session.dart';
import '../value_objects/auth_tokens.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn({
    required String username,
    required String password,
  });

  Future<AppUser> fetchCurrentUser();

  Future<AuthTokens> refreshSession({required String refreshToken});
}
