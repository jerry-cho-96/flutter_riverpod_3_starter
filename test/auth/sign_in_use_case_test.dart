import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/network/models/app_exception.dart';
import 'package:riverpod_origin_template/features/auth/application/usecases/sign_in_use_case.dart';

import '../helpers/test_doubles.dart';

void main() {
  group('SignInUseCase', () {
    test('입력값이 비어 있으면 validation 실패를 반환한다', () async {
      final useCase = SignInUseCase(FakeAuthRepository());

      final result = await useCase.call(username: ' ', password: '');

      result.when(
        success: (_) => fail('validation 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.validation);
          expect(error.message, '아이디와 비밀번호를 입력해 주세요.');
        },
      );
    });

    test('인증 오류면 unauthorized 실패를 반환한다', () async {
      final repository = FakeAuthRepository()
        ..signInResult = const AppException('Unauthorized', statusCode: 401);
      final useCase = SignInUseCase(repository);

      final result = await useCase.call(
        username: 'emilys',
        password: 'wrong-password',
      );

      result.when(
        success: (_) => fail('unauthorized 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.unauthorized);
          expect(error.message, 'Unauthorized');
        },
      );
    });

    test('네트워크 오류면 network 실패를 반환한다', () async {
      final repository = FakeAuthRepository()
        ..signInResult = const AppException('network error');
      final useCase = SignInUseCase(repository);

      final result = await useCase.call(
        username: 'emilys',
        password: 'emilyspass',
      );

      result.when(
        success: (_) => fail('network 실패가 예상됩니다.'),
        failure: (error) {
          expect(error.type, FailureType.network);
          expect(error.message, 'network error');
        },
      );
    });
  });
}
