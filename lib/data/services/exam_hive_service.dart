import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/features/exams/models/exam_item.dart';

class ExamHiveService {
  ExamHiveService._();

  static const String boxName = 'exams';
  static final ExamHiveService instance = ExamHiveService._();

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<dynamic>(boxName);
    }
  }

  bool get isInitialized => Hive.isBoxOpen(boxName);

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  ValueListenable<Box<dynamic>> listenable() => _box.listenable();

  Future<void> addExam(Exam exam) async {
    await _box.add(exam.toMap());
  }

  Future<void> deleteExam(dynamic key) async {
    await _box.delete(key);
  }

  List<ExamRecord> getSortedExamRecords() {
    if (!isInitialized) {
      return const <ExamRecord>[];
    }

    final records = <ExamRecord>[];

    for (final entry in _box.toMap().entries) {
      final value = entry.value;
      if (value is! Map) {
        continue;
      }

      try {
        final exam = Exam.fromMap(Map<dynamic, dynamic>.from(value));
        records.add(ExamRecord(key: entry.key, exam: exam));
      } catch (_) {
        // Ignore malformed records and keep UI stable.
      }
    }

    records.sort((a, b) => a.exam.date.compareTo(b.exam.date));
    return records;
  }

  int getUpcomingExamCount() {
    if (!isInitialized) {
      return 0;
    }

    return getSortedExamRecords()
        .where((record) => daysUntilExam(record.exam.date) >= 0)
        .length;
  }
}

class ExamRecord {
  const ExamRecord({required this.key, required this.exam});

  final dynamic key;
  final Exam exam;
}


