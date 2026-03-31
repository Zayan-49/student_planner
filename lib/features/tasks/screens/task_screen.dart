import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/data/models/task.dart';
import 'package:student_planner/data/services/task_hive_service.dart';
import 'package:student_planner/features/tasks/screens/add_task_screen.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppColors.background,
        elevation: 0,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ValueListenableBuilder<Box<Task>>(
            valueListenable: taskService.listenable(),
            builder: (context, _, __) {
              final tasks = taskService.getAllTasksSorted();

              if (tasks.isEmpty) {
                return Center(
                  child: Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final formattedDate = MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(task.dateTime);
                  final formattedTime = TimeOfDay.fromDateTime(
                    task.dateTime,
                  ).format(context);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            taskService.setTaskCompletion(
                              task: task,
                              isCompleted: value ?? false,
                            );
                          },
                          activeColor: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: task.isCompleted
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              if (task.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  task.description,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                '$formattedDate • $formattedTime',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final shouldDelete = await _showDeleteDialog(
                              context,
                            );
                            if (!shouldDelete) {
                              return;
                            }
                            await taskService.deleteTask(task);
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: AppColors.textSecondary,
                          tooltip: 'Delete task',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
