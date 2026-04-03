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
    extends $AsyncNotifierProvider<TodosController, List<Todo>> {
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

String _$todosControllerHash() => r'f37f79df13b5c297b9f1d20e90518271182583ee';

abstract class _$TodosController extends $AsyncNotifier<List<Todo>> {
  FutureOr<List<Todo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>, List<Todo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Todo>>, List<Todo>>,
              AsyncValue<List<Todo>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
