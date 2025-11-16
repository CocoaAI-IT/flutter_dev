import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/timer_session.dart';
import '../../data/repositories/timer_repository.dart';
import '../../../task/data/models/task.dart';
import '../../../task/data/repositories/task_repository.dart';

/// タイマーの状態
enum TimerStatus {
  idle,
  running,
  paused,
}

/// タイマーの状態クラス
class TimerState {
  final TimerStatus status;
  final Duration elapsed;
  final String? taskId;
  final DateTime? startedAt;
  final TimerSession? currentSession;

  const TimerState({
    this.status = TimerStatus.idle,
    this.elapsed = Duration.zero,
    this.taskId,
    this.startedAt,
    this.currentSession,
  });

  TimerState copyWith({
    TimerStatus? status,
    Duration? elapsed,
    String? taskId,
    DateTime? startedAt,
    TimerSession? currentSession,
  }) {
    return TimerState(
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      currentSession: currentSession ?? this.currentSession,
    );
  }

  bool get isRunning => status == TimerStatus.running;
  bool get isPaused => status == TimerStatus.paused;
  bool get isIdle => status == TimerStatus.idle;
}

/// TimerRepositoryのProvider
final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

/// TaskRepositoryのProvider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// タイマーのStateNotifierProvider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final timerRepository = ref.watch(timerRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TimerNotifier(
    timerRepository: timerRepository,
    taskRepository: taskRepository,
  );
});

/// タイマーのNotifier
class TimerNotifier extends StateNotifier<TimerState> {
  final TimerRepository timerRepository;
  final TaskRepository taskRepository;
  Timer? _timer;
  final Uuid _uuid = const Uuid();

  TimerNotifier({
    required this.timerRepository,
    required this.taskRepository,
  }) : super(const TimerState()) {
    _loadRunningSession();
  }

  /// 進行中のセッションを読み込み
  Future<void> _loadRunningSession() async {
    try {
      final runningSession = timerRepository.getRunningSession();
      if (runningSession != null) {
        final elapsed = DateTime.now().difference(runningSession.startTime);
        state = TimerState(
          status: TimerStatus.running,
          elapsed: elapsed,
          taskId: runningSession.taskId,
          startedAt: runningSession.startTime,
          currentSession: runningSession,
        );
        _startTimer();
      }
    } catch (e) {
      // エラーが発生した場合は初期状態のまま
    }
  }

  /// タイマーを開始
  Future<void> start(String taskId) async {
    if (state.isRunning) {
      return; // すでに実行中の場合は何もしない
    }

    try {
      final now = DateTime.now();
      final session = TimerSession(
        id: _uuid.v4(),
        taskId: taskId,
        startTime: now,
      );

      await timerRepository.createSession(session);

      state = TimerState(
        status: TimerStatus.running,
        elapsed: Duration.zero,
        taskId: taskId,
        startedAt: now,
        currentSession: session,
      );

      _startTimer();
    } catch (e) {
      // エラー処理
      throw Exception('Failed to start timer: $e');
    }
  }

  /// タイマーを一時停止
  void pause() {
    if (!state.isRunning) {
      return;
    }

    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  /// タイマーを再開
  void resume() {
    if (!state.isPaused) {
      return;
    }

    state = state.copyWith(status: TimerStatus.running);
    _startTimer();
  }

  /// タイマーを停止
  Future<void> stop() async {
    if (state.isIdle) {
      return;
    }

    _timer?.cancel();

    try {
      // セッションを更新
      if (state.currentSession != null) {
        final session = state.currentSession!;
        session.endTime = DateTime.now();
        session.durationInSeconds = state.elapsed.inSeconds;
        await timerRepository.updateSession(session);

        // タスクの総作業時間を更新
        if (state.taskId != null) {
          final task = taskRepository.getTaskById(state.taskId!);
          if (task != null) {
            task.addTime(state.elapsed);
            await taskRepository.updateTask(task);
          }
        }
      }

      state = const TimerState();
    } catch (e) {
      throw Exception('Failed to stop timer: $e');
    }
  }

  /// リセット
  Future<void> reset() async {
    _timer?.cancel();
    state = const TimerState();
  }

  /// タイマーを開始（内部用）
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startedAt != null) {
        final elapsed = DateTime.now().difference(state.startedAt!);
        state = state.copyWith(elapsed: elapsed);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 今日の総作業時間を取得するProvider
final todayTotalTimeProvider = Provider<Duration>((ref) {
  final timerRepository = ref.watch(timerRepositoryProvider);
  final sessions = timerRepository.getTodaySessions();
  int totalSeconds = 0;
  for (final session in sessions) {
    totalSeconds += session.durationInSeconds;
  }
  return Duration(seconds: totalSeconds);
});

/// 今週の総作業時間を取得するProvider
final thisWeekTotalTimeProvider = Provider<Duration>((ref) {
  final timerRepository = ref.watch(timerRepositoryProvider);
  final sessions = timerRepository.getThisWeekSessions();
  int totalSeconds = 0;
  for (final session in sessions) {
    totalSeconds += session.durationInSeconds;
  }
  return Duration(seconds: totalSeconds);
});
