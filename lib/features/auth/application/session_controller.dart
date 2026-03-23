import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/auth_session.dart';
import 'session_state.dart';
import 'usecases/persist_session_use_case.dart';
import 'usecases/restore_session_use_case.dart';
import 'usecases/sign_out_use_case.dart';

part 'session_controller.g.dart';

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  bool _didBootstrap = false;
  bool _isRestoring = false;

  @override
  SessionState build() {
    if (!_didBootstrap) {
      _didBootstrap = true;
      Future<void>.microtask(restoreSession);
    }

    return const SessionState.unknown();
  }

  Future<void> restoreSession() async {
    if (_isRestoring) {
      return;
    }

    _isRestoring = true;
    state = const SessionState.unknown();

    try {
      final outcome = await ref.read(restoreSessionUseCaseProvider).call();
      state = switch (outcome) {
        RestoreSessionAuthenticated(:final session) =>
          SessionState.authenticated(session: session),
        RestoreSessionUnauthenticated() => const SessionState.unauthenticated(),
        RestoreSessionFailure(:final failure) => SessionState.restorationFailed(
          failure: failure,
        ),
      };
    } finally {
      _isRestoring = false;
    }
  }

  Future<void> setSession(AuthSession session) async {
    await ref.read(persistSessionUseCaseProvider).call(session);
    state = SessionState.authenticated(session: session);
  }

  Future<void> signOut() async {
    await ref.read(signOutUseCaseProvider).call();
    state = const SessionState.unauthenticated();
  }
}
