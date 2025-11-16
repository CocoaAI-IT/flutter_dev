import 'package:hive/hive.dart';

part 'timer_session.g.dart';

/// タイマーセッション（作業記録）
@HiveType(typeId: 2)
class TimerSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final DateTime startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  int durationInSeconds;

  @HiveField(5)
  String? note;

  TimerSession({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
    this.durationInSeconds = 0,
    this.note,
  });

  /// セッションの継続時間をDurationで取得
  Duration get duration => Duration(seconds: durationInSeconds);

  /// セッションの継続時間を設定
  set duration(Duration value) {
    durationInSeconds = value.inSeconds;
  }

  /// セッションが進行中かどうか
  bool get isRunning => endTime == null;

  /// セッションを終了
  void stop() {
    endTime = DateTime.now();
    if (isRunning) {
      durationInSeconds = endTime!.difference(startTime).inSeconds;
    }
  }

  /// コピーを作成
  TimerSession copyWith({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationInSeconds,
    String? note,
  }) {
    return TimerSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'TimerSession(id: $id, taskId: $taskId, duration: $duration, '
        'isRunning: $isRunning)';
  }
}
