import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/features/exams/models/exam_item.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({
    required this.exam,
    required this.daysLeft,
    required this.onDelete,
    this.onLongPress,
    super.key,
  });

  final Exam exam;
  final int daysLeft;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isCompleted = daysLeft < 0;
    final bool isToday = daysLeft == 0;
    final bool isUrgent = daysLeft > 0 && daysLeft < 3;

    final statusColor = isCompleted
        ? AppColors.textSecondary
        : isToday
        ? AppColors.primary
        : isUrgent
        ? AppColors.warning
        : AppColors.textSecondary;

    final titleColor = isCompleted
        ? AppColors.textSecondary
        : AppColors.textPrimary;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0x1A4F46E5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _subjectIcon(exam.subject),
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.subject,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(context, exam.date),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusText(daysLeft),
                        style: textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete exam',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date.toLocal());
  }

  String _statusText(int days) {
    if (days == 0) {
      return 'Today is your exam! Best of luck!';
    }
    if (days == 1) {
      return '1 day left';
    }
    if (days > 1) {
      return '$days days left';
    }
    return 'Exam completed';
  }

  IconData _subjectIcon(String subject) {
    final value = subject.toLowerCase();

    if (value.contains('physics') || value.contains('chem')) {
      return Icons.science_rounded;
    }
    if (value.contains('math') || value.contains('algebra')) {
      return Icons.calculate_rounded;
    }
    if (value.contains('history') || value.contains('geo')) {
      return Icons.public_rounded;
    }
    if (value.contains('english') || value.contains('language')) {
      return Icons.menu_book_rounded;
    }

    return Icons.book_rounded;
  }
}
