import 'package:flutter/material.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';

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

    return SizedBox(
      width: 150,
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x3310B981),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(height: 14),
            Text(
              subject,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              countdown,
              style: textTheme.bodyMedium?.copyWith(
                color: isUrgent ? const Color(0xFFF59E0B) : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
