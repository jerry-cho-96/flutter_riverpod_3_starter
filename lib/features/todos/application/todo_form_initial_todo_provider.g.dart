// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_form_initial_todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoFormInitialTodo)
const todoFormInitialTodoProvider = TodoFormInitialTodoProvider._();

final class TodoFormInitialTodoProvider
    extends $FunctionalProvider<AsyncValue<Todo?>, Todo?, FutureOr<Todo?>>
    with $FutureModifier<Todo?>, $FutureProvider<Todo?> {
  const TodoFormInitialTodoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoFormInitialTodoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoFormInitialTodoHash();

  @$internal
  @override
  $FutureProviderElement<Todo?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Todo?> create(Ref ref) {
    return todoFormInitialTodo(ref);
  }
}

String _$todoFormInitialTodoHash() =>
    r'8fa6cb67715914a3367ec8a4cdce656d4edc743b';
