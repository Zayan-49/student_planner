import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/data/services/exam_hive_service.dart';
import 'package:student_planner/features/exams/screens/add_exam_screen.dart';
import 'package:student_planner/features/exams/models/exam_item.dart';
import 'package:student_planner/features/exams/widgets/exam_card.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exams'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExamScreen,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upcoming Exams',
                style: textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay prepared and never miss a test',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _examService.isInitialized
                    ? ValueListenableBuilder<Box<dynamic>>(
                        valueListenable: _examService.listenable(),
                        builder: (context, _, __) {
                          final records = _examService.getSortedExamRecords();

                          if (records.isEmpty) {
                            return const _ExamEmptyState();
                          }

                          return ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              final exam = record.exam;

                              return ExamCard(
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
    );
  }

  Future<void> _openAddExamScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AddExamScreen()),
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

class _ExamEmptyState extends StatelessWidget {
  const _ExamEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0x1A4F46E5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No exams added yet',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add your first exam',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
