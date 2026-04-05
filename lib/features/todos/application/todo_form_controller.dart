import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/entities/todo.dart';
import 'current_todo_user_id_provider.dart';
import 'usecases/save_todo_use_case.dart';

part 'todo_form_controller.g.dart';

@riverpod
class TodoFormController extends _$TodoFormController {
  @override
  FutureOr<void> build() {}

  Future<Todo> submit(String todoText, {required Todo? existingTodo}) async {
    if (state.isLoading) {
      throw StateError('이미 할 일 저장 요청을 처리 중입니다.');
    }

    state = const AsyncLoading<void>();
    final result = await ref
        .read(saveTodoUseCaseProvider)
        .call(
          todoText: todoText,
          existingTodo: existingTodo,
          userId: existingTodo == null
              ? ref.read(currentTodoUserIdProvider)
              : null,
        );

    return result.when(
      success: (todo) {
        state = const AsyncData<void>(null);
        return todo;
      },
      failure: (error) {
        state = const AsyncData<void>(null);
        throw error;
      },
    );
  }
}
