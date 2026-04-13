import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../auth/application/controllers/session_controller.dart';
import '../../../auth/application/states/session_state.dart';

part 'todo_user_id_provider.g.dart';

@Riverpod(keepAlive: true)
int todoUserId(Ref ref) {
  final sessionState = ref.watch(sessionControllerProvider);

  return switch (sessionState) {
    SessionAuthenticated(:final session) => session.user.id,
    _ => throw const AppFailure(
      message: '로그인된 사용자 정보를 확인할 수 없습니다.',
      type: FailureType.unauthorized,
    ),
  };
}
