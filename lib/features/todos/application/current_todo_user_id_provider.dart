import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/application/session_state.dart';

final currentTodoUserIdProvider = Provider<int>((ref) {
  final sessionState = ref.watch(sessionControllerProvider);

  return switch (sessionState) {
    SessionAuthenticated(:final session) => session.user.id,
    _ => throw const AppFailure(
      message: '로그인된 사용자 정보를 확인할 수 없습니다.',
      type: FailureType.unauthorized,
    ),
  };
});
