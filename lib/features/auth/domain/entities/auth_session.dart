import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_user.dart';
import '../value_objects/auth_tokens.dart';

part 'auth_session.freezed.dart';

@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required AppUser user,
    required AuthTokens tokens,
  }) = _AuthSession;
}
