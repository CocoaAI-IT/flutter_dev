import 'package:hive/hive.dart';
import '../models/timer_session.dart';

/// タイマーセッションのリポジトリ
class TimerRepository {
  static const String _boxName = 'timer_sessions';
  Box<TimerSession>? _box;

  /// Boxを初期化
  Future<void> init() async {
    _box = await Hive.openBox<TimerSession>(_boxName);
  }

  /// すべてのセッションを取得
  List<TimerSession> getAllSessions() {
    _ensureBoxOpen();
    return _box!.values.toList();
  }

  /// IDでセッションを取得
  TimerSession? getSessionById(String id) {
    _ensureBoxOpen();
    return _box!.get(id);
  }

  /// タスクIDでセッションを取得
  List<TimerSession> getSessionsByTaskId(String taskId) {
    _ensureBoxOpen();
    return _box!.values.where((session) => session.taskId == taskId).toList();
  }

  /// 進行中のセッションを取得
  TimerSession? getRunningSession() {
    _ensureBoxOpen();
    try {
      return _box!.values.firstWhere((session) => session.isRunning);
    } catch (e) {
      return null;
    }
  }

  /// 日付範囲でセッションを取得
  List<TimerSession> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    _ensureBoxOpen();
    return _box!.values.where((session) {
      return session.startTime.isAfter(startDate) &&
          session.startTime.isBefore(endDate);
    }).toList();
  }

  /// 今日のセッションを取得
  List<TimerSession> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getSessionsByDateRange(startOfDay, endOfDay);
  }

  /// 今週のセッションを取得
  List<TimerSession> getThisWeekSessions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endDate = startDate.add(const Duration(days: 7));
    return getSessionsByDateRange(startDate, endDate);
  }

  /// 今月のセッションを取得
  List<TimerSession> getThisMonthSessions() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 1);
    return getSessionsByDateRange(startDate, endDate);
  }

  /// セッションを作成
  Future<void> createSession(TimerSession session) async {
    _ensureBoxOpen();
    await _box!.put(session.id, session);
  }

  /// セッションを更新
  Future<void> updateSession(TimerSession session) async {
    _ensureBoxOpen();
    await _box!.put(session.id, session);
  }

  /// セッションを削除
  Future<void> deleteSession(String id) async {
    _ensureBoxOpen();
    await _box!.delete(id);
  }

  /// タスクに紐づくセッションをすべて削除
  Future<void> deleteSessionsByTaskId(String taskId) async {
    _ensureBoxOpen();
    final sessions = getSessionsByTaskId(taskId);
    for (final session in sessions) {
      await _box!.delete(session.id);
    }
  }

  /// すべてのセッションを削除
  Future<void> deleteAllSessions() async {
    _ensureBoxOpen();
    await _box!.clear();
  }

  /// タスクの総作業時間を計算
  Duration getTotalDurationByTaskId(String taskId) {
    final sessions = getSessionsByTaskId(taskId);
    int totalSeconds = 0;
    for (final session in sessions) {
      totalSeconds += session.durationInSeconds;
    }
    return Duration(seconds: totalSeconds);
  }

  /// 日付ごとの作業時間を計算
  Map<String, Duration> getDailyDurations(DateTime startDate, DateTime endDate) {
    final sessions = getSessionsByDateRange(startDate, endDate);
    final Map<String, int> dailySeconds = {};

    for (final session in sessions) {
      final dateKey =
          '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}-${session.startTime.day.toString().padLeft(2, '0')}';
      dailySeconds[dateKey] = (dailySeconds[dateKey] ?? 0) + session.durationInSeconds;
    }

    return dailySeconds.map(
      (key, value) => MapEntry(key, Duration(seconds: value)),
    );
  }

  /// Boxが開いているか確認
  void _ensureBoxOpen() {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
          'Timer session box is not initialized. Call init() first.');
    }
  }

  /// リポジトリをクローズ
  Future<void> close() async {
    await _box?.close();
  }
}
