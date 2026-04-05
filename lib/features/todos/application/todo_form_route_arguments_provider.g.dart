// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_form_route_arguments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoFormRouteArguments)
const todoFormRouteArgumentsProvider = TodoFormRouteArgumentsProvider._();

final class TodoFormRouteArgumentsProvider
    extends
        $FunctionalProvider<
          TodoFormRouteArguments,
          TodoFormRouteArguments,
          TodoFormRouteArguments
        >
    with $Provider<TodoFormRouteArguments> {
  const TodoFormRouteArgumentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoFormRouteArgumentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoFormRouteArgumentsHash();

  @$internal
  @override
  $ProviderElement<TodoFormRouteArguments> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodoFormRouteArguments create(Ref ref) {
    return todoFormRouteArguments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoFormRouteArguments value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoFormRouteArguments>(value),
    );
  }
}

String _$todoFormRouteArgumentsHash() =>
    r'881ee533fdd0966e9537ddb4ce9ae3a4c3a3201c';
