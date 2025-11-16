import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/time_formatter.dart';
import '../providers/timer_provider.dart';
import '../../../task/presentation/providers/task_provider.dart';
import '../../../task/data/models/task.dart';

/// タイマー画面
class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  String? _selectedTaskId;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final allTasks = ref.watch(allTasksProvider);
    final activeTasks = allTasks
        .where((task) => task.status != TaskStatus.done)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマー'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          children: [
            // タスク選択
            if (!timerState.isRunning) ...[
              _buildTaskSelector(activeTasks),
              const SizedBox(height: AppSizes.spaceLg),
            ],

            // タイマー表示
            _buildTimerDisplay(timerState),
            const SizedBox(height: AppSizes.spaceLg),

            // タイマーコントロール
            _buildTimerControls(timerState),
            const SizedBox(height: AppSizes.space2xl),

            // 今日のセッション履歴
            _buildTodaySessions(),
          ],
        ),
      ),
    );
  }

  /// タスク選択ドロップダウン
  Widget _buildTaskSelector(List<Task> tasks) {
    if (tasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spaceMd),
          child: Column(
            children: [
              const Icon(
                Icons.info_outline,
                size: AppSizes.iconLg,
                color: AppColors.info,
              ),
              const SizedBox(height: AppSizes.spaceSm),
              const Text('タスクがありません'),
              const SizedBox(height: AppSizes.spaceSm),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: タスク作成画面へ遷移
                },
                icon: const Icon(Icons.add),
                label: const Text('タスクを作成'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'タスクを選択',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            DropdownButtonFormField<String>(
              value: _selectedTaskId,
              decoration: const InputDecoration(
                hintText: 'タスクを選択してください',
              ),
              items: tasks.map((task) {
                return DropdownMenuItem<String>(
                  value: task.id,
                  child: Text(task.title),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTaskId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// タイマー表示
  Widget _buildTimerDisplay(TimerState timerState) {
    return Card(
      color: timerState.isRunning ? AppColors.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.space2xl),
        child: Column(
          children: [
            // ステータスアイコン
            Icon(
              timerState.isRunning
                  ? Icons.play_circle_filled
                  : timerState.isPaused
                      ? Icons.pause_circle_filled
                      : Icons.timer_outlined,
              size: AppSizes.iconXl,
              color: timerState.isRunning ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: AppSizes.spaceMd),

            // 経過時間
            Text(
              TimeFormatter.formatDuration(timerState.elapsed),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: timerState.isRunning
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),

            // ステータステキスト
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              timerState.isRunning
                  ? '稼働中'
                  : timerState.isPaused
                      ? '一時停止中'
                      : '停止中',
              style: TextStyle(
                fontSize: 16,
                color: timerState.isRunning
                    ? Colors.white70
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// タイマーコントロール
  Widget _buildTimerControls(TimerState timerState) {
    if (timerState.isRunning) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(timerProvider.notifier).pause();
              },
              icon: const Icon(Icons.pause),
              label: const Text('一時停止'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(timerProvider.notifier).stop();
                setState(() {
                  _selectedTaskId = null;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('タイマーを停止しました')),
                  );
                }
              },
              icon: const Icon(Icons.stop),
              label: const Text('停止'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else if (timerState.isPaused) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(timerProvider.notifier).resume();
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('再開'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(timerProvider.notifier).stop();
                setState(() {
                  _selectedTaskId = null;
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('タイマーを停止しました')),
                  );
                }
              },
              icon: const Icon(Icons.stop),
              label: const Text('停止'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _selectedTaskId == null
              ? null
              : () async {
                  try {
                    await ref
                        .read(timerProvider.notifier)
                        .start(_selectedTaskId!);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('タイマーを開始しました')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('エラー: $e')),
                      );
                    }
                  }
                },
          icon: const Icon(Icons.play_arrow),
          label: const Text('開始'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(AppSizes.buttonHeightLg),
          ),
        ),
      );
    }
  }

  /// 今日のセッション履歴
  Widget _buildTodaySessions() {
    final timerRepository = ref.watch(timerRepositoryProvider);
    final sessions = timerRepository.getTodaySessions()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日の記録',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final task = ref
                .read(taskRepositoryProvider)
                .getTaskById(session.taskId);

            return Card(
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: Text(task?.title ?? '不明なタスク'),
                subtitle: Text(
                  '${TimeFormatter.formatDurationHuman(session.duration)} - ${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: session.isRunning
                    ? const Chip(
                        label: Text('稼働中'),
                        backgroundColor: AppColors.primary,
                        labelStyle: TextStyle(color: Colors.white),
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
