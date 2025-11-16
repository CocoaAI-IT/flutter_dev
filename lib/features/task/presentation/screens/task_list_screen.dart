import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/time_formatter.dart';
import '../providers/task_provider.dart';
import '../../data/models/task.dart';

/// タスク一覧画面
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  TaskStatus _selectedStatus = TaskStatus.todo;

  @override
  Widget build(BuildContext context) {
    final todoTasks = ref.watch(todoTasksProvider);
    final inProgressTasks = ref.watch(inProgressTasksProvider);
    final doneTasks = ref.watch(doneTasksProvider);

    List<Task> displayTasks;
    switch (_selectedStatus) {
      case TaskStatus.todo:
        displayTasks = todoTasks;
        break;
      case TaskStatus.inProgress:
        displayTasks = inProgressTasks;
        break;
      case TaskStatus.done:
        displayTasks = doneTasks;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク'),
      ),
      body: Column(
        children: [
          // ステータスタブ
          _buildStatusTabs(todoTasks.length, inProgressTasks.length,
              doneTasks.length),

          // タスクリスト
          Expanded(
            child: displayTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.spaceMd),
                    itemCount: displayTasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(displayTasks[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('タスク追加'),
      ),
    );
  }

  /// ステータスタブ
  Widget _buildStatusTabs(int todoCount, int inProgressCount, int doneCount) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: _buildStatusTab(
              'ToDo',
              TaskStatus.todo,
              todoCount,
              AppColors.taskTodo,
            ),
          ),
          Expanded(
            child: _buildStatusTab(
              '進行中',
              TaskStatus.inProgress,
              inProgressCount,
              AppColors.taskInProgress,
            ),
          ),
          Expanded(
            child: _buildStatusTab(
              '完了',
              TaskStatus.done,
              doneCount,
              AppColors.taskDone,
            ),
          ),
        ],
      ),
    );
  }

  /// ステータスタブ（個別）
  Widget _buildStatusTab(
    String label,
    TaskStatus status,
    int count,
    Color color,
  ) {
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceMd),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// タスクカード
  Widget _buildTaskCard(Task task) {
    Color statusColor;
    switch (task.status) {
      case TaskStatus.todo:
        statusColor = AppColors.taskTodo;
        break;
      case TaskStatus.inProgress:
        statusColor = AppColors.taskInProgress;
        break;
      case TaskStatus.done:
        statusColor = AppColors.taskDone;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spaceMd),
      child: InkWell(
        onTap: () => _showTaskDetailDialog(context, task),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: statusColor, width: 4),
            ),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _buildPriorityBadge(task.priority),
                  ],
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSizes.spaceSm),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: AppSizes.iconSm,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Text(
                      TimeFormatter.formatDurationHuman(task.totalDuration),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (task.tags.isNotEmpty)
                      Wrap(
                        spacing: AppSizes.spaceXs,
                        children: task.tags
                            .take(2)
                            .map((tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 優先度バッジ
  Widget _buildPriorityBadge(int priority) {
    Color color;
    String label;

    switch (priority) {
      case 3:
        color = AppColors.error;
        label = '高';
        break;
      case 2:
        color = AppColors.warning;
        label = '中';
        break;
      case 1:
        color = AppColors.info;
        label = '低';
        break;
      default:
        color = AppColors.textSecondary;
        label = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceSm,
        vertical: AppSizes.spaceXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 空の状態
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: AppSizes.iconXl * 2,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppSizes.spaceMd),
          Text(
            'タスクがありません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSizes.spaceSm),
          const Text('「タスク追加」ボタンから\nタスクを作成してください'),
        ],
      ),
    );
  }

  /// タスク追加ダイアログ
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int priority = 2;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新しいタスク'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'タスク名',
                    hintText: 'タスク名を入力',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSizes.spaceMd),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '説明（任意）',
                    hintText: '説明を入力',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSizes.spaceMd),
                Row(
                  children: [
                    const Text('優先度: '),
                    const SizedBox(width: AppSizes.spaceSm),
                    ChoiceChip(
                      label: const Text('低'),
                      selected: priority == 1,
                      onSelected: (selected) {
                        if (selected) setState(() => priority = 1);
                      },
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    ChoiceChip(
                      label: const Text('中'),
                      selected: priority == 2,
                      onSelected: (selected) {
                        if (selected) setState(() => priority = 2);
                      },
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    ChoiceChip(
                      label: const Text('高'),
                      selected: priority == 3,
                      onSelected: (selected) {
                        if (selected) setState(() => priority = 3);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('タスク名を入力してください')),
                  );
                  return;
                }

                await ref.read(taskNotifierProvider.notifier).createTask(
                      title: titleController.text,
                      description: descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      priority: priority,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('タスクを作成しました')),
                  );
                }
              },
              child: const Text('作成'),
            ),
          ],
        ),
      ),
    );
  }

  /// タスク詳細ダイアログ
  void _showTaskDetailDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) ...[
              Text(task.description!),
              const SizedBox(height: AppSizes.spaceMd),
            ],
            _buildInfoRow(
              '総作業時間',
              TimeFormatter.formatDurationHuman(task.totalDuration),
            ),
            _buildInfoRow('作成日', task.createdAt.toString().substring(0, 10)),
            if (task.completedAt != null)
              _buildInfoRow(
                  '完了日', task.completedAt.toString().substring(0, 10)),
          ],
        ),
        actions: [
          if (task.status != TaskStatus.done)
            TextButton.icon(
              onPressed: () async {
                await ref
                    .read(taskNotifierProvider.notifier)
                    .completeTask(task.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('タスクを完了しました')),
                  );
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('完了にする'),
            ),
          TextButton.icon(
            onPressed: () async {
              await ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('タスクを削除しました')),
                );
              }
            },
            icon: const Icon(Icons.delete, color: AppColors.error),
            label: const Text('削除', style: TextStyle(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 情報行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spaceXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
