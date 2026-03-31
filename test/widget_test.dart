// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:student_planner/data/services/task_hive_service.dart';

import 'package:student_planner/main.dart';

void main() {
  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp('student_planner_test');
    Hive.init(tempDirectory.path);
    await TaskHiveService.instance.init();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  testWidgets('Dashboard renders key planner content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudentPlannerApp());

    expect(find.text('Hello, Ali 👋'), findsOneWidget);
    expect(find.text("Let's stay productive today"), findsOneWidget);
    expect(find.text('Tasks Today'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Upcoming Exams'), findsWidgets);
    expect(find.text('No upcoming exams'), findsOneWidget);
    expect(find.text("Today's Tasks"), findsOneWidget);
  });
}
