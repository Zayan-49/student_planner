import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/services/exam_hive_service.dart';
import 'package:student_planner/features/dashboard/widgets/exam_card.dart';
import 'package:student_planner/features/exams/models/exam_item.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';

class UpcomingExamsSection extends StatelessWidget {
  const UpcomingExamsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final examService = ExamHiveService.instance;

    if (!examService.isInitialized) {
      return const SizedBox(height: 146, child: _EmptyUpcomingExams());
    }

    return SizedBox(
      height: 146,
      child: ValueListenableBuilder<Box<dynamic>>(
        valueListenable: examService.listenable(),
        builder: (context, _, child) {
          final records = examService
              .getSortedExamRecords()
              .where((record) => daysUntilExam(record.exam.date) >= 0)
              .toList();

          if (records.isEmpty) {
            return const _EmptyUpcomingExams();
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: records.length,
            separatorBuilder: (_, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final exam = records[index].exam;
              final daysLeft = daysUntilExam(exam.date);

              return ExamCard(
                icon: _subjectIcon(exam.subject),
                subject: exam.subject,
                countdown: _countdownLabel(daysLeft),
                isUrgent: daysLeft >= 0 && daysLeft < 3,
              );
            },
          );
        },
      ),
    );
  }

  String _countdownLabel(int daysLeft) {
    if (daysLeft == 0) {
      return 'Today';
    }
    if (daysLeft == 1) {
      return '1 day left';
    }
    return '$daysLeft days left';
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

class _EmptyUpcomingExams extends StatelessWidget {
  const _EmptyUpcomingExams();

  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      borderRadius: 20,
      child: Center(
        child: Text(
          'No upcoming exams',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
