import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_origin_template/core/errors/app_failure.dart';
import 'package:riverpod_origin_template/features/auth/application/session_controller.dart';
import 'package:riverpod_origin_template/features/auth/application/session_state.dart';
import 'package:riverpod_origin_template/features/auth/presentation/splash_screen.dart';

void main() {
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
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    expect(find.text('네트워크를 확인해 주세요.'), findsOneWidget);
    expect(find.text('세션 복구 다시 시도'), findsOneWidget);
  });
}
