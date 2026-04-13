import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'session_controller.dart';
import '../usecases/sign_in_use_case.dart';

part 'sign_in_controller.g.dart';

@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await ref
          .read(signInUseCaseProvider)
          .call(username: username, password: password);
      final session = result.when(
        success: (session) => session,
        failure: (error) => throw error,
      );
      await ref.read(sessionControllerProvider.notifier).setSession(session);
    });
  }
}
