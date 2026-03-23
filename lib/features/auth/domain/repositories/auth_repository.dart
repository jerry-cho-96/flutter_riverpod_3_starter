import '../../../../core/storage/auth_tokens.dart';
import '../entities/app_user.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> signIn({
    required String username,
    required String password,
  });

  Future<AppUser> fetchCurrentUser();

  Future<AuthTokens> refreshSession({required String refreshToken});
}
