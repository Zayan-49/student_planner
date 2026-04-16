import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/models/task.dart';
import 'package:student_planner/data/services/task_hive_service.dart';
import 'package:student_planner/features/tasks/screens/add_task_screen.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';
import 'package:student_planner/theme/widgets/gradient_background.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  Future<bool> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final taskService = TaskHiveService.instance;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AddTaskScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add task',
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<Box<Task>>(
              valueListenable: taskService.listenable(),
              builder: (context, box, child) {
                final tasks = taskService.getAllTasksSorted();

                if (tasks.isEmpty) {
                  return Center(
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 22,
                      ),
                      child: Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final formattedDate = MaterialLocalizations.of(
                      context,
                    ).formatMediumDate(task.dateTime);
                    final formattedTime = TimeOfDay.fromDateTime(
                      task.dateTime,
                    ).format(context);

                    return _TaskGlassCard(
                      task: task,
                      formattedDate: formattedDate,
                      formattedTime: formattedTime,
                      onToggleCompleted: (value) {
                        taskService.setTaskCompletion(
                          task: task,
                          isCompleted: value,
                        );
                      },
                      onDelete: () async {
                        final shouldDelete = await _showDeleteDialog(context);
                        if (!shouldDelete) {
                          return;
                        }
                        await taskService.deleteTask(task);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskGlassCard extends StatelessWidget {
  const _TaskGlassCard({
    required this.task,
    required this.formattedDate,
    required this.formattedTime,
    required this.onToggleCompleted,
    required this.onDelete,
  });

  final Task task;
  final String formattedDate;
  final String formattedTime;
  final ValueChanged<bool> onToggleCompleted;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = task.isCompleted;

    return Opacity(
      opacity: isCompleted ? 0.72 : 1,
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) => onToggleCompleted(value ?? false),
                  activeColor: AppTheme.primary,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Color(0x66FFFFFF), width: 1.2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppTheme.textSecondary,
                  tooltip: 'Delete task',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '$formattedDate • $formattedTime',
                  style: textTheme.bodySmall?.copyWith(
                    color: isCompleted ? AppTheme.textSecondary : AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
