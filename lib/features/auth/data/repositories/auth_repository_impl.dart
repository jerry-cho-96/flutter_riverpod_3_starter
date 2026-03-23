import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/auth_tokens.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/refresh_token_response_dto.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> fetchCurrentUser() async {
    final dto = await _remoteDataSource.fetchCurrentUser();
    return _mapUser(dto);
  }

  @override
  Future<AuthTokens> refreshSession({required String refreshToken}) async {
    final dto = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );
    return _mapTokens(dto);
  }

  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
  }) async {
    final dto = await _remoteDataSource.signIn(
      username: username,
      password: password,
    );

    return AuthSession(
      user: AppUser(
        id: dto.id,
        username: dto.username,
        email: dto.email,
        firstName: dto.firstName,
        lastName: dto.lastName,
        image: dto.image,
      ),
      tokens: AuthTokens(
        accessToken: dto.accessToken,
        refreshToken: dto.refreshToken,
      ),
    );
  }

  AppUser _mapUser(UserDto dto) {
    return AppUser(
      id: dto.id,
      username: dto.username,
      email: dto.email,
      firstName: dto.firstName,
      lastName: dto.lastName,
      image: dto.image,
    );
  }

  AuthTokens _mapTokens(RefreshTokenResponseDto dto) {
    return AuthTokens(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
    );
  }
}
