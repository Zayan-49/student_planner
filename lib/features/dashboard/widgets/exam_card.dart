import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({
    required this.icon,
    required this.subject,
    required this.countdown,
    this.isUrgent = false,
    super.key,
  });

  final IconData icon;
  final String subject;
  final String countdown;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 130,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0x1A4F46E5),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            subject,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            countdown,
            style: textTheme.bodyMedium?.copyWith(
              color: isUrgent ? AppColors.warning : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

