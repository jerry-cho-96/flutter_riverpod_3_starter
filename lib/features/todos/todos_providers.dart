import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/todos_remote_data_source.dart';
import 'data/repositories/todos_repository_impl.dart';
import 'domain/repositories/todos_repository.dart';

/// Todos feature 공개 DI 진입점. repository wiring 만 담당한다.
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepositoryImpl(ref.watch(todosRemoteDataSourceProvider));
});
