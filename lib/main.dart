import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/services/exam_hive_service.dart';
import 'package:student_planner/data/services/task_hive_service.dart';
import 'package:student_planner/navigation/main_navigation_screen.dart';
import 'package:student_planner/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await TaskHiveService.instance.init();
  await ExamHiveService.instance.init();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // App still starts without .env; AI replies with a fallback message.
  }

  runApp(const StudentPlannerApp());
}

class StudentPlannerApp extends StatelessWidget {
  const StudentPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Planner',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

