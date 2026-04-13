// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_user_id_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todoUserId)
const todoUserIdProvider = TodoUserIdProvider._();

final class TodoUserIdProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  const TodoUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoUserIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoUserIdHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return todoUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$todoUserIdHash() => r'dd04817f96b816216ee1ebf1925d0090f2febfe1';
