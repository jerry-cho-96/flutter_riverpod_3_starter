import 'package:riverpod_origin_template/core/storage/auth_tokens.dart';
import 'package:riverpod_origin_template/core/storage/token_storage.dart';
import 'package:riverpod_origin_template/features/auth/domain/entities/app_user.dart';
import 'package:riverpod_origin_template/features/auth/domain/entities/auth_session.dart';
import 'package:riverpod_origin_template/features/auth/domain/repositories/auth_repository.dart';

AuthTokens createTokens({
  String accessToken = 'access-token',
  String refreshToken = 'refresh-token',
}) {
  return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}

AppUser createUser({
  int id = 1,
  String username = 'emilys',
  String email = 'emilys@dummyjson.com',
  String firstName = 'Emily',
  String lastName = 'Stone',
  String? image = 'https://cdn.dummyjson.com/users/1.png',
}) {
  return AppUser(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    image: image,
  );
}

AuthSession createSession({AuthTokens? tokens, AppUser? user}) {
  return AuthSession(
    user: user ?? createUser(),
    tokens: tokens ?? createTokens(),
  );
}

class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.storedTokens]);

  AuthTokens? storedTokens;
  int saveCallCount = 0;
  int clearCallCount = 0;

  @override
  Future<void> clear() async {
    clearCallCount += 1;
    storedTokens = null;
  }

  @override
  Future<AuthTokens?> read() async => storedTokens;

  @override
  Future<void> save(AuthTokens tokens) async {
    saveCallCount += 1;
    storedTokens = tokens;
  }
}

class FakeAuthRepository implements AuthRepository {
  final List<Object> currentUserResults = <Object>[];
  Object? signInResult;
  Object? refreshResult;
  int signInCallCount = 0;
  int refreshCallCount = 0;
  int fetchCurrentUserCallCount = 0;

  void enqueueCurrentUserResult(Object result) {
    currentUserResults.add(result);
  }

  @override
  Future<AppUser> fetchCurrentUser() async {
    fetchCurrentUserCallCount += 1;
    if (currentUserResults.isEmpty) {
      throw StateError('No current user response configured');
    }

    final result = currentUserResults.removeAt(0);
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as AppUser;
  }

  @override
  Future<AuthTokens> refreshSession({required String refreshToken}) async {
    refreshCallCount += 1;
    return _resolve<AuthTokens>(
      refreshResult,
      fallback: StateError('No refresh result configured'),
    );
  }

  @override
  Future<AuthSession> signIn({
    required String username,
    required String password,
  }) async {
    signInCallCount += 1;
    return _resolve<AuthSession>(
      signInResult,
      fallback: StateError('No sign-in result configured'),
    );
  }

  T _resolve<T>(Object? value, {required Object fallback}) {
    final result = value ?? fallback;
    if (result is Exception) {
      throw result;
    }
    if (result is Error) {
      throw result;
    }

    return result as T;
  }
}
