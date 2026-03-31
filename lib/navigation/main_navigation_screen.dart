import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/features/ai/screens/ai_chat_screen.dart';
import 'package:student_planner/features/dashboard/screens/dashboard_screen.dart';
import 'package:student_planner/features/exams/screens/exam_screen.dart';
import 'package:student_planner/features/tasks/screens/task_screen.dart';
import 'package:student_planner/features/timer/screens/timer_screen.dart';

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
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.primary);
              }
              return const IconThemeData(color: AppColors.textSecondary);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                );
              }
              return const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Colors.white,
            indicatorColor: const Color(0x1A4F46E5),
            surfaceTintColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
    );
  }
}
