import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/async_value_view.dart';
import '../application/todo_form_controller.dart';
import '../application/todo_form_initial_todo_provider.dart';
import '../application/todo_form_route_arguments_provider.dart';
import '../application/todos_controller.dart';
import '../domain/entities/todo.dart';

class TodoFormScreen extends ConsumerWidget {
  const TodoFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeArguments = ref.watch(todoFormRouteArgumentsProvider);
    final initialTodoAsync = ref.watch(todoFormInitialTodoProvider);

    return AsyncValueView<Todo?>(
      value: initialTodoAsync,
      loadingLabel: routeArguments.isEdit
          ? '할 일 정보를 불러오는 중입니다...'
          : '할 일 폼을 준비하는 중입니다...',
      onRetry: () => ref.invalidate(todoFormInitialTodoProvider),
      data: (initialTodo) => _TodoFormContent(
        key: ValueKey(
          '${routeArguments.todoId ?? 'create'}-${initialTodo?.id ?? 'new'}',
        ),
        initialTodo: initialTodo,
      ),
    );
  }
}

class _TodoFormContent extends ConsumerStatefulWidget {
  const _TodoFormContent({super.key, required this.initialTodo});

  final Todo? initialTodo;

  @override
  ConsumerState<_TodoFormContent> createState() => _TodoFormContentState();
}

class _TodoFormContentState extends ConsumerState<_TodoFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _todoController;

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController(
      text: widget.initialTodo?.todo ?? '',
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArguments = ref.watch(todoFormRouteArgumentsProvider);
    final submitAsync = ref.watch(todoFormControllerProvider);
    final isSubmitting = submitAsync.isLoading;
    final title = routeArguments.isEdit ? '할 일 수정' : '할 일 추가';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      routeArguments.isEdit
                          ? '기존 할 일 내용을 수정해 mutation form 흐름과 deep link 복구를 검증합니다.'
                          : '별도 create form 화면에서 입력 검증과 submit 상태를 검증합니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _todoController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '할 일 내용',
                        hintText: '예: CI 워크플로우 정리하기',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '할 일 내용을 입력해 주세요.';
                        }

                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              routeArguments.isEdit
                                  ? Icons.save_rounded
                                  : Icons.add_task_rounded,
                            ),
                      label: Text(isSubmitting ? '저장 중...' : '저장'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final routeArguments = ref.read(todoFormRouteArgumentsProvider);
    try {
      final savedTodo = await ref
          .read(todoFormControllerProvider.notifier)
          .submit(_todoController.text, existingTodo: widget.initialTodo);
      ref
          .read(todosControllerProvider.notifier)
          .applySavedTodo(savedTodo, isNew: !routeArguments.isEdit);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              routeArguments.isEdit ? '할 일을 수정했습니다.' : '할 일을 추가했습니다.',
            ),
          ),
        );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is AppFailure ? error.message : '할 일을 저장하지 못했습니다.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
