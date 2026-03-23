import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../domain/entities/auth_session.dart';

part 'session_state.freezed.dart';

@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState.unknown() = SessionUnknown;

  const factory SessionState.restorationFailed({required AppFailure failure}) =
      SessionRestorationFailed;

  const factory SessionState.unauthenticated() = SessionUnauthenticated;

  const factory SessionState.authenticated({required AuthSession session}) =
      SessionAuthenticated;
}
