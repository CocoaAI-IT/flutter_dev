import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'features/task/data/models/task.dart';
import 'features/timer/data/models/timer_session.dart';
import 'features/dashboard/data/models/daily_stats.dart';
import 'features/task/data/repositories/task_repository.dart';
import 'features/timer/data/repositories/timer_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveの初期化
  await Hive.initFlutter();

  // Hiveアダプターの登録
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TimerSessionAdapter());
  Hive.registerAdapter(DailyStatsAdapter());

  // リポジトリの初期化
  final taskRepository = TaskRepository();
  final timerRepository = TimerRepository();

  try {
    await taskRepository.init();
    await timerRepository.init();
  } catch (e) {
    debugPrint('Error initializing repositories: $e');
  }

  runApp(
    const ProviderScope(
      child: WorkTimeTrackerApp(),
    ),
  );
}
