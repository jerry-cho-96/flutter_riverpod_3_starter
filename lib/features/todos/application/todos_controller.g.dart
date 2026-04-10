// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodosController)
const todosControllerProvider = TodosControllerProvider._();

final class TodosControllerProvider
    extends $AsyncNotifierProvider<TodosController, TodosListState> {
  const TodosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosControllerHash();

  @$internal
  @override
  TodosController create() => TodosController();
}

String _$todosControllerHash() => r'95ece514a4b3a91d345eac84de74fecaa1e96849';

abstract class _$TodosController extends $AsyncNotifier<TodosListState> {
  FutureOr<TodosListState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<TodosListState>, TodosListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodosListState>, TodosListState>,
              AsyncValue<TodosListState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
