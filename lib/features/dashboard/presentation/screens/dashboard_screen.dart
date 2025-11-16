import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../timer/presentation/providers/timer_provider.dart';
import '../../../task/presentation/providers/task_provider.dart';

/// ダッシュボード画面
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotalTime = ref.watch(todayTotalTimeProvider);
    final thisWeekTotalTime = ref.watch(thisWeekTotalTimeProvider);
    final taskStats = ref.watch(taskStatsProvider);
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ダッシュボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 設定画面への遷移
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイマー状態表示
            if (timerState.isRunning) ...[
              _buildActiveTimerCard(context, timerState),
              const SizedBox(height: AppSizes.spaceMd),
            ],

            // 統計カード
            _buildStatsSection(
              context,
              todayTotalTime,
              thisWeekTotalTime,
              taskStats,
            ),

            const SizedBox(height: AppSizes.spaceLg),

            // タスク概要
            _buildTaskOverview(context, taskStats),
          ],
        ),
      ),
    );
  }

  /// アクティブなタイマーカード
  Widget _buildActiveTimerCard(BuildContext context, TimerState timerState) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.timer, color: Colors.white),
                SizedBox(width: AppSizes.spaceSm),
                Text(
                  '稼働中',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              TimeFormatter.formatDuration(timerState.elapsed),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 統計セクション
  Widget _buildStatsSection(
    BuildContext context,
    Duration todayTotalTime,
    Duration thisWeekTotalTime,
    TaskStats taskStats,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日の記録',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                '今日',
                TimeFormatter.formatDurationHuman(todayTotalTime),
                Icons.today,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSizes.spaceMd),
            Expanded(
              child: _buildStatCard(
                context,
                '今週',
                TimeFormatter.formatDurationHuman(thisWeekTotalTime),
                Icons.date_range,
                AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 統計カード
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppSizes.iconMd),
                const SizedBox(width: AppSizes.spaceSm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// タスク概要
  Widget _buildTaskOverview(BuildContext context, TaskStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'タスク概要',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSizes.spaceMd),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            child: Column(
              children: [
                _buildTaskStatusRow(
                  context,
                  'ToDo',
                  stats.todoCount,
                  AppColors.taskTodo,
                ),
                const Divider(),
                _buildTaskStatusRow(
                  context,
                  '進行中',
                  stats.inProgressCount,
                  AppColors.taskInProgress,
                ),
                const Divider(),
                _buildTaskStatusRow(
                  context,
                  '完了',
                  stats.doneCount,
                  AppColors.taskDone,
                ),
                const SizedBox(height: AppSizes.spaceMd),
                LinearProgressIndicator(
                  value: stats.completionRate,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                Text(
                  '完了率: ${(stats.completionRate * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// タスクステータス行
  Widget _buildTaskStatusRow(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
