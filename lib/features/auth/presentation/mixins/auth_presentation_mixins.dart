import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/app_failure.dart';
import '../../application/controllers/session_controller.dart';
import '../../application/controllers/sign_in_controller.dart';
import '../../application/states/session_state.dart';

mixin class AuthPresentationStateMixin {
  AsyncValue<void> watchSignInState(WidgetRef ref) {
    return ref.watch(signInControllerProvider);
  }

  SessionState watchSessionState(WidgetRef ref) {
    return ref.watch(sessionControllerProvider);
  }

  String? pendingRoute(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters['from'];
  }

  String? restorationFailureMessage(WidgetRef ref) {
    final sessionState = watchSessionState(ref);
    return switch (sessionState) {
      SessionRestorationFailed(:final failure) => failure.message,
      _ => null,
    };
  }
}

mixin class AuthPresentationEventMixin {
  Future<void> ensureSessionRestore(WidgetRef ref) {
    return ref.read(sessionControllerProvider.notifier).ensureSessionRestored();
  }

  void listenSignInFailure(WidgetRef ref, BuildContext context) {
    ref.listen<AsyncValue<void>>(signInControllerProvider, (previous, next) {
      if (!next.hasError || previous == next) {
        return;
      }

      final error = next.error;
      final message = error is AppFailure ? error.message : '로그인에 실패했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    });
  }

  Future<void> submitSignIn(
    WidgetRef ref, {
    required String username,
    required String password,
  }) {
    return ref
        .read(signInControllerProvider.notifier)
        .signIn(username: username, password: password);
  }

  Future<void> retrySessionRestore(WidgetRef ref) {
    return ref.read(sessionControllerProvider.notifier).restoreSession();
  }
}
