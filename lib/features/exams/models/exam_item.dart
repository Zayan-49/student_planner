class Exam {
  final String subject;
  final DateTime date;

  const Exam({required this.subject, required this.date});

  factory Exam.fromMap(Map<dynamic, dynamic> map) {
    final rawSubject = map['subject'];
    final rawDate = map['date'];

    if (rawSubject is! String || rawDate is! String) {
      throw const FormatException('Invalid exam payload');
    }

    return Exam(subject: rawSubject, date: DateTime.parse(rawDate));
  }

  Map<String, String> toMap() {
    return <String, String>{'subject': subject, 'date': date.toIso8601String()};
  }
}

int daysUntilExam(DateTime examDate, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final examDay = DateTime(examDate.year, examDate.month, examDate.day);
  return examDay.difference(today).inDays;
}
