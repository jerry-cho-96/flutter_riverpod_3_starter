import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../features/auth/application/session_controller.dart';

class AuthenticatedShell extends ConsumerWidget {
  const AuthenticatedShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(config.appName),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await ref.read(sessionControllerProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('로그아웃'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(bottom: false, child: child),
    );
  }
}
