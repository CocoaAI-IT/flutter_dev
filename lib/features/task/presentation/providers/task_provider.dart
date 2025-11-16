import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../../timer/presentation/providers/timer_provider.dart';

/// TaskRepositoryの再エクスポート（timerProviderから既に提供されている）
// TaskRepositoryProviderはtimerProviderで既に定義されているため不要

/// すべてのタスクを取得するProvider
final allTasksProvider = Provider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  try {
    return repository.getAllTasks();
  } catch (e) {
    return [];
  }
});

/// TodoタスクのProvider
final todoTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.where((task) => task.status == TaskStatus.todo).toList();
});

/// 進行中タスクのProvider
final inProgressTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.where((task) => task.status == TaskStatus.inProgress).toList();
});

/// 完了タスクのProvider
final doneTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(allTasksProvider);
  return tasks.where((task) => task.status == TaskStatus.done).toList();
});

/// タスクのStateNotifierProvider
final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository: repository, ref: ref);
});

/// タスクのNotifier
class TaskNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository repository;
  final Ref ref;
  final Uuid _uuid = const Uuid();

  TaskNotifier({
    required this.repository,
    required this.ref,
  }) : super(const AsyncValue.data(null));

  /// タスクを作成
  Future<void> createTask({
    required String title,
    String? description,
    List<String>? tags,
    int priority = 2,
  }) async {
    state = const AsyncValue.loading();

    try {
      final task = Task(
        id: _uuid.v4(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        tags: tags,
        priority: priority,
      );

      await repository.createTask(task);
      state = const AsyncValue.data(null);

      // タスク一覧を更新
      ref.invalidate(allTasksProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクを更新
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();

    try {
      await repository.updateTask(task);
      state = const AsyncValue.data(null);

      // タスク一覧を更新
      ref.invalidate(allTasksProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクを削除
  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();

    try {
      await repository.deleteTask(id);
      state = const AsyncValue.data(null);

      // タスク一覧を更新
      ref.invalidate(allTasksProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクのステータスを変更
  Future<void> changeTaskStatus(Task task, TaskStatus newStatus) async {
    state = const AsyncValue.loading();

    try {
      final updatedTask = task.copyWith(status: newStatus);

      if (newStatus == TaskStatus.done) {
        updatedTask.completedAt = DateTime.now();
      } else {
        updatedTask.completedAt = null;
      }

      await repository.updateTask(updatedTask);
      state = const AsyncValue.data(null);

      // タスク一覧を更新
      ref.invalidate(allTasksProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクを完了にする
  Future<void> completeTask(String id) async {
    try {
      final task = repository.getTaskById(id);
      if (task != null) {
        await changeTaskStatus(task, TaskStatus.done);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクを進行中にする
  Future<void> startTask(String id) async {
    try {
      final task = repository.getTaskById(id);
      if (task != null) {
        await changeTaskStatus(task, TaskStatus.inProgress);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクをTodoに戻す
  Future<void> resetTask(String id) async {
    try {
      final task = repository.getTaskById(id);
      if (task != null) {
        await changeTaskStatus(task, TaskStatus.todo);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクの優先度を変更
  Future<void> updateTaskPriority(String id, int priority) async {
    state = const AsyncValue.loading();

    try {
      final task = repository.getTaskById(id);
      if (task != null) {
        final updatedTask = task.copyWith(priority: priority);
        await repository.updateTask(updatedTask);
        state = const AsyncValue.data(null);

        ref.invalidate(allTasksProvider);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクにタグを追加
  Future<void> addTagToTask(String taskId, String tag) async {
    state = const AsyncValue.loading();

    try {
      final task = repository.getTaskById(taskId);
      if (task != null) {
        final tags = List<String>.from(task.tags);
        if (!tags.contains(tag)) {
          tags.add(tag);
          final updatedTask = task.copyWith(tags: tags);
          await repository.updateTask(updatedTask);
          state = const AsyncValue.data(null);

          ref.invalidate(allTasksProvider);
        }
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// タスクからタグを削除
  Future<void> removeTagFromTask(String taskId, String tag) async {
    state = const AsyncValue.loading();

    try {
      final task = repository.getTaskById(taskId);
      if (task != null) {
        final tags = List<String>.from(task.tags);
        tags.remove(tag);
        final updatedTask = task.copyWith(tags: tags);
        await repository.updateTask(updatedTask);
        state = const AsyncValue.data(null);

        ref.invalidate(allTasksProvider);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// タスク統計のProvider
final taskStatsProvider = Provider<TaskStats>((ref) {
  final tasks = ref.watch(allTasksProvider);

  int todoCount = 0;
  int inProgressCount = 0;
  int doneCount = 0;
  Duration totalTime = Duration.zero;

  for (final task in tasks) {
    switch (task.status) {
      case TaskStatus.todo:
        todoCount++;
        break;
      case TaskStatus.inProgress:
        inProgressCount++;
        break;
      case TaskStatus.done:
        doneCount++;
        break;
    }
    totalTime += task.totalDuration;
  }

  return TaskStats(
    totalCount: tasks.length,
    todoCount: todoCount,
    inProgressCount: inProgressCount,
    doneCount: doneCount,
    totalTime: totalTime,
  );
});

/// タスク統計クラス
class TaskStats {
  final int totalCount;
  final int todoCount;
  final int inProgressCount;
  final int doneCount;
  final Duration totalTime;

  TaskStats({
    required this.totalCount,
    required this.todoCount,
    required this.inProgressCount,
    required this.doneCount,
    required this.totalTime,
  });

  double get completionRate {
    if (totalCount == 0) return 0.0;
    return doneCount / totalCount;
  }
}
