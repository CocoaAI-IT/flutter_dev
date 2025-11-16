import 'package:hive/hive.dart';
import '../models/task.dart';

/// タスクのリポジトリ
class TaskRepository {
  static const String _boxName = 'tasks';
  Box<Task>? _box;

  /// Boxを初期化
  Future<void> init() async {
    _box = await Hive.openBox<Task>(_boxName);
  }

  /// すべてのタスクを取得
  List<Task> getAllTasks() {
    _ensureBoxOpen();
    return _box!.values.toList();
  }

  /// IDでタスクを取得
  Task? getTaskById(String id) {
    _ensureBoxOpen();
    return _box!.values.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task not found: $id'),
    );
  }

  /// ステータス別にタスクを取得
  List<Task> getTasksByStatus(TaskStatus status) {
    _ensureBoxOpen();
    return _box!.values.where((task) => task.status == status).toList();
  }

  /// タスクを作成
  Future<void> createTask(Task task) async {
    _ensureBoxOpen();
    await _box!.put(task.id, task);
  }

  /// タスクを更新
  Future<void> updateTask(Task task) async {
    _ensureBoxOpen();
    await _box!.put(task.id, task);
  }

  /// タスクを削除
  Future<void> deleteTask(String id) async {
    _ensureBoxOpen();
    await _box!.delete(id);
  }

  /// すべてのタスクを削除
  Future<void> deleteAllTasks() async {
    _ensureBoxOpen();
    await _box!.clear();
  }

  /// Todoタスクを取得
  List<Task> getTodoTasks() {
    return getTasksByStatus(TaskStatus.todo);
  }

  /// 進行中タスクを取得
  List<Task> getInProgressTasks() {
    return getTasksByStatus(TaskStatus.inProgress);
  }

  /// 完了タスクを取得
  List<Task> getCompletedTasks() {
    return getTasksByStatus(TaskStatus.done);
  }

  /// 優先度順にタスクを取得
  List<Task> getTasksByPriority() {
    _ensureBoxOpen();
    final tasks = _box!.values.toList();
    tasks.sort((a, b) => b.priority.compareTo(a.priority));
    return tasks;
  }

  /// 作成日時順にタスクを取得
  List<Task> getTasksByCreatedDate({bool ascending = false}) {
    _ensureBoxOpen();
    final tasks = _box!.values.toList();
    tasks.sort((a, b) {
      return ascending
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt);
    });
    return tasks;
  }

  /// タグでフィルタリング
  List<Task> getTasksByTag(String tag) {
    _ensureBoxOpen();
    return _box!.values.where((task) => task.tags.contains(tag)).toList();
  }

  /// タスク数を取得
  int getTaskCount() {
    _ensureBoxOpen();
    return _box!.length;
  }

  /// ステータス別のタスク数を取得
  int getTaskCountByStatus(TaskStatus status) {
    return getTasksByStatus(status).length;
  }

  /// Boxが開いているか確認
  void _ensureBoxOpen() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Task box is not initialized. Call init() first.');
    }
  }

  /// リポジトリをクローズ
  Future<void> close() async {
    await _box?.close();
  }
}
