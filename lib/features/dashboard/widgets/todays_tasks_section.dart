import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/models/task.dart';
import 'package:student_planner/data/services/task_hive_service.dart';
import 'package:student_planner/features/dashboard/widgets/task_tile.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';

class TodaysTasksSection extends StatelessWidget {
  const TodaysTasksSection({super.key});

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
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

    return shouldDelete ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final taskService = TaskHiveService.instance;

    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<Box<Task>>(
        valueListenable: taskService.listenable(),
        builder: (context, _, child) {
          final todaysTasks = taskService.getTasksForDay(DateTime.now());

          if (todaysTasks.isEmpty) {
            return Text(
              'No tasks for today yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            );
          }

          return Column(
            children: [
              for (var i = 0; i < todaysTasks.length; i++) ...[
                TaskTile(
                  title: todaysTasks[i].value.title,
                  description: todaysTasks[i].value.description,
                  statusText: todaysTasks[i].value.isCompleted
                      ? 'Completed'
                      : 'Due by ${TimeOfDay.fromDateTime(todaysTasks[i].value.dateTime).format(context)}',
                  isCompleted: todaysTasks[i].value.isCompleted,
                  isChecked: todaysTasks[i].value.isCompleted,
                  onChanged: (isChecked) {
                    final value = isChecked ?? false;
                    taskService.setTaskCompletion(
                      task: todaysTasks[i].value,
                      isCompleted: value,
                    );
                  },
                  onDelete: () async {
                    final shouldDelete = await _showDeleteConfirmationDialog(
                      context,
                    );
                    if (!shouldDelete) {
                      return;
                    }

                    await taskService.deleteTask(todaysTasks[i].value);
                  },
                ),
                if (i != todaysTasks.length - 1) ...[
                  const SizedBox(height: 4),
                  const Divider(height: 16, color: Color(0x33FFFFFF)),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
