import 'package:flutter/material.dart';
import 'package:student_planner/features/ai/screens/ai_chat_screen.dart';
import 'package:student_planner/features/dashboard/screens/dashboard_screen.dart';
import 'package:student_planner/features/exams/screens/exam_screen.dart';
import 'package:student_planner/features/tasks/screens/task_screen.dart';
import 'package:student_planner/features/timer/screens/timer_screen.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    TaskScreen(),
    ExamScreen(),
    TimerScreen(),
    AiChatScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: GlassContainer(
          borderRadius: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          blurSigma: 20,

          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0x3310B981),
              height: 72,
              labelTextStyle:
                  WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 0,
                  );
                }
                return const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 0,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppTheme.primary, size: 28);
                }
                return const IconThemeData(
                  color: Color.fromRGBO(255, 255, 255, 0.72),
                  size: 26,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: const Color(0x3310B981),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_task_rounded),
                  label: 'Add Task',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_rounded),
                  label: 'Exams',
                ),
                NavigationDestination(
                  icon: Icon(Icons.timer_rounded),
                  label: 'Timer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_rounded),
                  label: 'AI',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
