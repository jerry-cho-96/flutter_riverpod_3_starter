import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/app_failure.dart';

typedef AsyncValueBuilder<T> = Widget Function(T value);

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loadingLabel = '불러오는 중입니다...',
    this.onRetry,
  });

  final AsyncValue<T> value;
  final AsyncValueBuilder<T> data;
  final String loadingLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => _StatusBox(
        icon: const CircularProgressIndicator(),
        message: loadingLabel,
      ),
      error: (error, stackTrace) => _StatusBox(
        icon: const Icon(Icons.error_outline_rounded, size: 32),
        message: switch (error) {
          AppFailure(:final message) => message,
          _ => '알 수 없는 오류가 발생했습니다.',
        },
        onRetry: onRetry,
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.icon, required this.message, this.onRetry});

  final Widget icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 220),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          icon,
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
}
