import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/presentation/async_value_view.dart';
import '../application/todos_list_state.dart';
import '../domain/entities/todo.dart';
import 'todos_presentation_mixins.dart';

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen>
    with TodosPresentationStateMixin, TodosPresentationEventMixin {
  late final TextEditingController _todoController;
  bool _isCreating = false;
  final Set<int> _pendingTodoIds = <int>{};

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

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
                      '이 화면은 새 feature에 목록 조회와 추가, 수정, 삭제 흐름을 함께 얹어도 스타터킷 구조가 유지되는지 검증합니다.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _todoController,
                      enabled: !_isCreating && !isTodosLoading,
                      decoration: const InputDecoration(
                        labelText: '새 할 일',
                        hintText: '예: build_runner 정리하기',
                      ),
                      onSubmitted: (_) => _submitTodo(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isCreating || isTodosLoading
                          ? null
                          : _submitTodo,
                      icon: _isCreating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_task_rounded),
                      label: Text(_isCreating ? '추가 중...' : '할 일 추가'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            AsyncValueView<TodosListState>(
              value: todosAsync,
              loadingLabel: '할 일 목록을 불러오는 중입니다...',
              onRetry: () => refreshTodos(ref),
              data: (pageState) {
                final todos = pageState.items;
                if (todos.isEmpty) {
                  return const _EmptyTodosCard();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TodosSummary(pageState: pageState),
                    const SizedBox(height: 16),
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
                        onToggle: () => _toggleTodo(todos[index]),
                        onDelete: () => _deleteTodo(todos[index]),
                      ),
                      if (index != todos.length - 1) const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 16),
                    _TodosPaginationFooter(
                      pageState: pageState,
                      onLoadMore: () => loadMoreTodos(ref),
                    ),
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

  Future<void> _submitTodo() async {
    setState(() => _isCreating = true);
    try {
      await addTodo(ref, _todoController.text);
      if (!mounted) {
        return;
      }
      _todoController.clear();
      _showMessage('할 일을 추가했습니다.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showError(error);
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
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

class _TodosSummary extends StatelessWidget {
  const _TodosSummary({required this.pageState});

  final TodosListState pageState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '총 ${pageState.totalCount}개 항목',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            Chip(
              avatar: const Icon(Icons.sync_rounded),
              label: Text(
                '동기화 ${pageState.loadedRemoteCount}/${pageState.remoteTotalCount}',
              ),
            ),
            if (pageState.localOnlyCount > 0)
              Chip(
                avatar: const Icon(Icons.cloud_off_rounded),
                label: Text('로컬 추가 ${pageState.localOnlyCount}개'),
              ),
            if (pageState.remoteRemainingCount > 0)
              Chip(
                avatar: const Icon(Icons.more_horiz_rounded),
                label: Text('남은 원격 ${pageState.remoteRemainingCount}개'),
              ),
          ],
        ),
      ],
    );
  }
}

class _TodosPaginationFooter extends StatelessWidget {
  const _TodosPaginationFooter({
    required this.pageState,
    required this.onLoadMore,
  });

  final TodosListState pageState;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final failure = pageState.loadMoreFailure;
    if (pageState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (failure != null) {
      return Column(
        children: <Widget>[
          Text(failure.message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onLoadMore,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('할 일 더 불러오기 재시도'),
          ),
        ],
      );
    }

    if (!pageState.hasMore) {
      return const SizedBox.shrink();
    }

    return OutlinedButton.icon(
      onPressed: onLoadMore,
      icon: const Icon(Icons.expand_more_rounded),
      label: const Text('할 일 더 보기'),
    );
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
            Text('위 입력창에서 첫 할 일을 추가해 보세요.', style: theme.textTheme.bodyMedium),
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
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final bool isPending;
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
