import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_presentation_mixins.dart';

class SplashScreen extends ConsumerWidget
    with AuthPresentationStateMixin, AuthPresentationEventMixin {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final failureMessage = restorationFailureMessage(ref);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0B2C2A),
              Color(0xFF114945),
              Color(0xFFF4F7F2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.layers_rounded,
                  size: 46,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Riverpod Origin Template',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                failureMessage ?? '세션을 복구하고 라우팅 상태를 확인하는 중입니다.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              if (failureMessage == null)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              else
                FilledButton.icon(
                  onPressed: () async => retrySessionRestore(ref),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('세션 복구 다시 시도'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
