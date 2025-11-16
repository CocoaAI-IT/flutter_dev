import 'package:hive/hive.dart';

part 'task.g.dart';

/// タスクのステータス
@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  done,
}

/// タスクモデル
@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  int totalTimeInSeconds;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  int priority; // 1: 低, 2: 中, 3: 高

  Task({
    required this.id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.totalTimeInSeconds = 0,
    required this.createdAt,
    this.completedAt,
    List<String>? tags,
    this.priority = 2,
  }) : tags = tags ?? [];

  /// 総作業時間をDurationで取得
  Duration get totalDuration => Duration(seconds: totalTimeInSeconds);

  /// 総作業時間を設定
  set totalDuration(Duration duration) {
    totalTimeInSeconds = duration.inSeconds;
  }

  /// 作業時間を追加
  void addTime(Duration duration) {
    totalTimeInSeconds += duration.inSeconds;
  }

  /// タスクを完了にする
  void markAsCompleted() {
    status = TaskStatus.done;
    completedAt = DateTime.now();
  }

  /// タスクを進行中にする
  void markAsInProgress() {
    status = TaskStatus.inProgress;
  }

  /// タスクをTodoに戻す
  void markAsTodo() {
    status = TaskStatus.todo;
    completedAt = null;
  }

  /// コピーを作成
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    int? totalTimeInSeconds,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? tags,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, '
        'totalTime: $totalDuration)';
  }
}
