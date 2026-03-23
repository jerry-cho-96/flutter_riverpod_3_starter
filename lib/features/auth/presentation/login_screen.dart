import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/template_example.dart';
import '../../../core/errors/app_failure.dart';
import '../application/sign_in_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: kDebugMode ? TemplateExample.exampleUsername : '',
    );
    _passwordController = TextEditingController(
      text: kDebugMode ? TemplateExample.examplePassword : '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final signInState = ref.watch(signInControllerProvider);
    final pendingRoute = GoRouterState.of(context).uri.queryParameters['from'];
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF092E2D),
              Color(0xFF145A54),
              Color(0xFFE9F4EE),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Riverpod Origin Template',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  TemplateExample.loginDescription,
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: const <Widget>[
                                    Chip(label: Text('Riverpod 3')),
                                    Chip(label: Text('go_router')),
                                    Chip(
                                      label: Text(
                                        TemplateExample.authChipLabel,
                                      ),
                                    ),
                                  ],
                                ),
                                if (pendingRoute != null &&
                                    pendingRoute.isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 20),
                                  _NoticeCard(
                                    label: '보호된 경로 접근',
                                    value: '로그인 후 $pendingRoute 로 복귀합니다.',
                                  ),
                                ],
                                const SizedBox(height: 20),
                                const _NoticeCard(
                                  label: '예제 계정',
                                  value: TemplateExample
                                      .exampleCredentialsDescription,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const <String>[
                                    AutofillHints.username,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    hintText: TemplateExample.exampleUsername,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '아이디를 입력해 주세요.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  autofillHints: const <String>[
                                    AutofillHints.password,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    hintText: TemplateExample.examplePassword,
                                  ),
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '비밀번호를 입력해 주세요.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                FilledButton.icon(
                                  onPressed: signInState.isLoading
                                      ? null
                                      : _submit,
                                  icon: signInState.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.login_rounded),
                                  label: Text(
                                    signInState.isLoading ? '로그인 중...' : '로그인',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await ref
        .read(signInControllerProvider.notifier)
        .signIn(
          username: _usernameController.text,
          password: _passwordController.text,
        );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
