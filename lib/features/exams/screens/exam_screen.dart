import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/services/exam_hive_service.dart';
import 'package:student_planner/features/exams/models/exam_item.dart';
import 'package:student_planner/features/exams/screens/add_exam_screen.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';
import 'package:student_planner/theme/widgets/gradient_background.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final ExamHiveService _examService = ExamHiveService.instance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Exams'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppTheme.textPrimary,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AddExamScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add task',
          ),
        ],
      ),

      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 16),
                Expanded(
                  child: _examService.isInitialized
                      ? ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: _examService.listenable(),
                          builder: (context, box, child) {
                            final records = _examService.getSortedExamRecords();

                            if (records.isEmpty) {
                              return const _ExamEmptyState();
                            }

                            return ListView.builder(
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final record = records[index];
                                final exam = record.exam;

                                return _GlassExamCard(
                                  exam: exam,
                                  daysLeft: daysUntilExam(exam.date),
                                  onDelete: () => _deleteExam(record.key),
                                  onLongPress: () =>
                                      _showDeleteConfirmation(record),
                                );
                              },
                            );
                          },
                        )
                      : const _ExamEmptyState(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _showDeleteConfirmation(ExamRecord record) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete exam?'),
          content: Text(
            'Are you sure you want to delete ${record.exam.subject}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _deleteExam(record.key);
  }

  Future<void> _deleteExam(dynamic key) async {
    await _examService.deleteExam(key);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exam deleted')));
  }
}

class _GlassExamCard extends StatelessWidget {
  const _GlassExamCard({
    required this.exam,
    required this.daysLeft,
    required this.onDelete,
    this.onLongPress,
  });

  final Exam exam;
  final int daysLeft;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCompleted = daysLeft < 0;
    final isToday = daysLeft == 0;
    final isUrgent = daysLeft > 0 && daysLeft < 3;

    final statusColor = isCompleted
        ? AppTheme.textSecondary
        : isToday
            ? AppTheme.secondary
            : isUrgent
                ? const Color(0xFFF59E0B)
                : AppTheme.textSecondary;

    final titleColor = isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary;

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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: 20,
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onLongPress: onLongPress,
              child: Opacity(
                opacity: isCompleted ? 0.7 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0x3310B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _subjectIcon(exam.subject),
                          color: AppTheme.primary,
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
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(context, exam.date),
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
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
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class _ExamEmptyState extends StatelessWidget {
  const _ExamEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: GlassContainer(
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0x3310B981),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 34,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No exams added yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add your first exam',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
