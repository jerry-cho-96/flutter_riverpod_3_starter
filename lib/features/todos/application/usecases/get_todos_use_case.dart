import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/network/models/app_exception.dart';
import '../../../../core/pagination/page_chunk.dart';
import '../../../../core/result/query_result_cache.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../../todos_providers.dart';

final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  return GetTodosUseCase(ref.watch(todosRepositoryProvider));
});

class GetTodosUseCase {
  GetTodosUseCase(this._repository);

  final TodosRepository _repository;
  final QueryResultCache<(int, int, int), Result<PageChunk<Todo>>> _cache =
      QueryResultCache<(int, int, int), Result<PageChunk<Todo>>>();

  Future<Result<PageChunk<Todo>>> call({
    required int userId,
    required int limit,
    required int skip,
  }) async {
    if (userId <= 0 || limit <= 0 || skip < 0) {
      return const Failure<PageChunk<Todo>>(
        AppFailure(
          message: '유효한 할 일 목록 요청이 아닙니다.',
          type: FailureType.validation,
        ),
      );
    }

    return _cache.run((userId, limit, skip), () async {
      try {
        final todos = await _repository.fetchTodosByUser(
          userId: userId,
          limit: limit,
          skip: skip,
        );
        return Success<PageChunk<Todo>>(todos);
      } on AppException catch (error) {
        return Failure<PageChunk<Todo>>(AppFailure.fromAppException(error));
      } catch (error) {
        return Failure<PageChunk<Todo>>(
          AppFailure.fromObject(error, fallbackMessage: '할 일 목록을 불러오지 못했습니다.'),
        );
      }
    }, shouldCache: (result) => result is Success<PageChunk<Todo>>);
  }

  void clearCache() {
    _cache.clear();
  }
}
