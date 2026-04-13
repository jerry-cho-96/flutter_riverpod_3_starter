import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/todo.dart';

const Object _unsetLoadMoreFailure = Object();

class TodosListState {
  const TodosListState({
    required this.items,
    required this.pageSize,
    required this.remoteTotalCount,
    required this.loadedRemoteCount,
    required this.localOnlyCount,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  factory TodosListState.empty({required int pageSize}) {
    return TodosListState(
      items: const <Todo>[],
      pageSize: pageSize,
      remoteTotalCount: 0,
      loadedRemoteCount: 0,
      localOnlyCount: 0,
    );
  }

  final List<Todo> items;
  final int pageSize;
  final int remoteTotalCount;
  final int loadedRemoteCount;
  final int localOnlyCount;
  final bool isLoadingMore;
  final AppFailure? loadMoreFailure;

  int get displayedCount => items.length;

  int get totalCount => remoteTotalCount + localOnlyCount;

  bool get hasMore => loadedRemoteCount < remoteTotalCount;

  int get nextRemoteSkip => loadedRemoteCount;

  int get remoteRemainingCount => remoteTotalCount - loadedRemoteCount;

  TodosListState copyWith({
    List<Todo>? items,
    int? pageSize,
    int? remoteTotalCount,
    int? loadedRemoteCount,
    int? localOnlyCount,
    bool? isLoadingMore,
    Object? loadMoreFailure = _unsetLoadMoreFailure,
  }) {
    return TodosListState(
      items: items ?? this.items,
      pageSize: pageSize ?? this.pageSize,
      remoteTotalCount: remoteTotalCount ?? this.remoteTotalCount,
      loadedRemoteCount: loadedRemoteCount ?? this.loadedRemoteCount,
      localOnlyCount: localOnlyCount ?? this.localOnlyCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure: identical(loadMoreFailure, _unsetLoadMoreFailure)
          ? this.loadMoreFailure
          : loadMoreFailure as AppFailure?,
    );
  }

  TodosListState beginLoadMore() {
    return copyWith(isLoadingMore: true, loadMoreFailure: null);
  }

  TodosListState appendRemotePage(
    List<Todo> nextItems, {
    required int fetchedCount,
    required int remoteTotalCount,
    required int localOnlyCount,
  }) {
    return copyWith(
      items: <Todo>[...items, ...nextItems],
      remoteTotalCount: remoteTotalCount,
      loadedRemoteCount: loadedRemoteCount + fetchedCount,
      localOnlyCount: localOnlyCount,
      isLoadingMore: false,
      loadMoreFailure: null,
    );
  }

  TodosListState failLoadMore(AppFailure failure) {
    return copyWith(isLoadingMore: false, loadMoreFailure: failure);
  }
}
