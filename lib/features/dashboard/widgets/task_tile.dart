import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.title,
    required this.description,
    required this.statusText,
    required this.isCompleted,
    required this.isChecked,
    this.onChanged,
    this.onDelete,
    super.key,
  });

  final String title;
  final String description;
  final String statusText;
  final bool isCompleted;
  final bool isChecked;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          decoration: isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.trim().isNotEmpty) ...[
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              statusText,
              style: textTheme.bodyMedium?.copyWith(
                color: isCompleted ? AppColors.success : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Delete task',
          ),
        ],
      ),
    );
  }
}
