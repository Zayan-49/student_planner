import 'package:flutter/material.dart';
import 'package:student_planner/theme/app_theme.dart';

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
          color: isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.trim().isNotEmpty) ...[
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              statusText,
              style: textTheme.bodyMedium?.copyWith(
                color: isCompleted ? AppTheme.secondary : const Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
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
            activeColor: AppTheme.primary,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            side: const BorderSide(color: Color(0x66FFFFFF), width: 1.2),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppTheme.textSecondary,
            tooltip: 'Delete task',
          ),
        ],
      ),
    );
  }
}
