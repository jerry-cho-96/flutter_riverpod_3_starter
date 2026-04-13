import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/core/storage/token_storage.dart';
import 'package:riverpod_origin_template/features/auth/auth_providers.dart';
import 'package:riverpod_origin_template/features/auth/application/controllers/session_controller.dart';
import 'package:riverpod_origin_template/features/auth/application/states/session_state.dart';
import 'package:riverpod_origin_template/features/auth/presentation/screens/splash_screen.dart';

import '../helpers/test_doubles.dart';

void main() {
  testWidgets('초기 진입 시 세션 복구를 한 번 시작한다', (tester) async {
    final repository = FakeAuthRepository();
    final storage = FakeTokenStorage();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        tokenStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();

    expect(repository.fetchCurrentUserCallCount, 0);
    expect(storage.clearCallCount, 0);
    expect(
      container.read(sessionControllerProvider),
      const SessionState.unauthenticated(),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('restorationFailed 상태면 재시도 버튼을 노출한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWithValue(
            const SessionState.restorationFailed(
              failure: AppFailure(
                message: '네트워크를 확인해 주세요.',
                type: FailureType.network,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: SplashScreen(autoRestoreSession: false)),
      ),
    );

    expect(find.text('네트워크를 확인해 주세요.'), findsOneWidget);
    expect(find.text('세션 복구 다시 시도'), findsOneWidget);
  });
}
