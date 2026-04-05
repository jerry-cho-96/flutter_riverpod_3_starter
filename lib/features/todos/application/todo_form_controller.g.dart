// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoFormController)
const todoFormControllerProvider = TodoFormControllerProvider._();

final class TodoFormControllerProvider
    extends $AsyncNotifierProvider<TodoFormController, void> {
  const TodoFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoFormControllerHash();

  @$internal
  @override
  TodoFormController create() => TodoFormController();
}

String _$todoFormControllerHash() =>
    r'd286373ac050f3ce343e3e98335203c2ffc681a7';

abstract class _$TodoFormController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
