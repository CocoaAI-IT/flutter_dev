import 'package:hive/hive.dart';

part 'daily_stats.g.dart';

/// 日次統計データ
@HiveType(typeId: 3)
class DailyStats extends HiveObject {
  @HiveField(0)
  final String date; // yyyy-MM-dd形式

  @HiveField(1)
  int totalTimeInSeconds;

  @HiveField(2)
  int pomodoroCount;

  @HiveField(3)
  int completedTaskCount;

  @HiveField(4)
  Map<String, int> taskTimeMap; // taskId -> seconds

  DailyStats({
    required this.date,
    this.totalTimeInSeconds = 0,
    this.pomodoroCount = 0,
    this.completedTaskCount = 0,
    Map<String, int>? taskTimeMap,
  }) : taskTimeMap = taskTimeMap ?? {};

  /// 総作業時間をDurationで取得
  Duration get totalDuration => Duration(seconds: totalTimeInSeconds);

  /// 作業時間を追加
  void addTime(Duration duration, String taskId) {
    totalTimeInSeconds += duration.inSeconds;
    taskTimeMap[taskId] = (taskTimeMap[taskId] ?? 0) + duration.inSeconds;
  }

  /// ポモドーロカウントを増やす
  void incrementPomodoro() {
    pomodoroCount++;
  }

  /// 完了タスクカウントを増やす
  void incrementCompletedTask() {
    completedTaskCount++;
  }

  /// ヒートマップの強度レベルを計算（0-4）
  int get intensityLevel {
    final hours = totalDuration.inHours;
    if (hours == 0) return 0;
    if (hours < 1) return 1;
    if (hours < 2) return 2;
    if (hours < 4) return 3;
    return 4;
  }

  /// コピーを作成
  DailyStats copyWith({
    String? date,
    int? totalTimeInSeconds,
    int? pomodoroCount,
    int? completedTaskCount,
    Map<String, int>? taskTimeMap,
  }) {
    return DailyStats(
      date: date ?? this.date,
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
      taskTimeMap: taskTimeMap ?? this.taskTimeMap,
    );
  }

  @override
  String toString() {
    return 'DailyStats(date: $date, totalTime: $totalDuration, '
        'pomodoros: $pomodoroCount, completed: $completedTaskCount)';
  }
}
