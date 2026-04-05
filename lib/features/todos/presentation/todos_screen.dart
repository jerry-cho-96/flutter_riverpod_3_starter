import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/async_value_view.dart';
import '../domain/entities/todo.dart';
import 'todos_presentation_mixins.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen>
    with TodosPresentationStateMixin, TodosPresentationEventMixin {
  final Set<int> _pendingTodoIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final todosAsync = watchTodos(ref);
    final isTodosLoading = todosAsync.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('할 일 관리')),
      body: RefreshIndicator(
        onRefresh: () => refreshTodos(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Mutation Dry Run', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '이 화면은 목록 화면을 유지한 채 별도 create/edit form 라우트를 추가해도 스타터킷 구조가 유지되는지 검증합니다.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: isTodosLoading ? null : _openCreateForm,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('할 일 추가 폼 열기'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AsyncValueView<List<Todo>>(
              value: todosAsync,
              loadingLabel: '할 일 목록을 불러오는 중입니다...',
              onRetry: () => refreshTodos(ref),
              data: (todos) {
                if (todos.isEmpty) {
                  return const _EmptyTodosCard();
                }

                return Column(
                  children: <Widget>[
                    for (
                      var index = 0;
                      index < todos.length;
                      index++
                    ) ...<Widget>[
                      _TodoCard(
                        todo: todos[index],
                        isPending:
                            isTodosLoading ||
                            _pendingTodoIds.contains(todos[index].id),
                        onEdit: () => _openEditForm(todos[index]),
                        onToggle: () => _toggleTodo(todos[index]),
                        onDelete: () => _deleteTodo(todos[index]),
                      ),
                      if (index != todos.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTodo(Todo todo) async {
    setState(() => _pendingTodoIds.add(todo.id));
    try {
      await deleteTodo(ref, todo);
      if (!mounted) {
        return;
      }
      _showMessage('할 일을 삭제했습니다.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _pendingTodoIds.remove(todo.id));
      }
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    setState(() => _pendingTodoIds.add(todo.id));
    try {
      await toggleTodoCompletion(ref, todo);
      if (!mounted) {
        return;
      }
      _showMessage(todo.completed ? '할 일을 진행 중으로 변경했습니다.' : '할 일을 완료했습니다.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _pendingTodoIds.remove(todo.id));
      }
    }
  }

  Future<void> _openCreateForm() async {
    await context.push(AppRoute.todoCreate.path);
  }

  Future<void> _openEditForm(Todo todo) async {
    await context.push(
      AppRoute.todoEdit.location(
        pathParameters: <String, String>{'todoId': todo.id.toString()},
      ),
      extra: todo,
    );
  }

  void _showError(Object error) {
    final message = error is AppFailure ? error.message : '요청을 처리하지 못했습니다.';
    _showSnackBar(message);
  }

  void _showMessage(String message) {
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _EmptyTodosCard extends StatelessWidget {
  const _EmptyTodosCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('할 일이 없습니다.', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '위 버튼으로 create form 화면을 열어 첫 할 일을 추가해 보세요.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.isPending,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final bool isPending;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: todo.completed,
              onChanged: isPending ? null : (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    todo.todo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todo.completed ? '완료된 할 일' : '진행 중인 할 일',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isPending ? null : onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('수정'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: isPending ? null : onDelete,
              icon: isPending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
              tooltip: '삭제',
            ),
          ],
        ),
      ),
    );
  }
}
