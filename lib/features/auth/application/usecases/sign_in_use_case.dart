import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/result/result.dart';
import '../../auth_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

class SignInUseCase {
  const SignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<AuthSession>> call({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return const Failure<AuthSession>(
        AppFailure(
          message: '아이디와 비밀번호를 입력해 주세요.',
          type: FailureType.validation,
        ),
      );
    }

    try {
      final session = await _authRepository.signIn(
        username: username,
        password: password,
      );
      return Success<AuthSession>(session);
    } on AppException catch (error) {
      return Failure<AuthSession>(AppFailure.fromAppException(error));
    } catch (error) {
      return Failure<AuthSession>(
        AppFailure.fromObject(error, fallbackMessage: '로그인 요청을 처리하지 못했습니다.'),
      );
    }
  }
}
