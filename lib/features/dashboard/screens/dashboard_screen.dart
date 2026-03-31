import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/features/dashboard/widgets/overview_cards_section.dart';
import 'package:student_planner/features/dashboard/widgets/todays_tasks_section.dart';
import 'package:student_planner/features/dashboard/widgets/upcoming_exams_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, Ali 👋', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                "Let's stay productive today",
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              const OverviewCardsSection(),
              const SizedBox(height: 24),
              Text(
                'Upcoming Exams',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const UpcomingExamsSection(),
              const SizedBox(height: 24),
              Text(
                "Today's Tasks",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const TodaysTasksSection(),
            ],
          ),
        ),
      ),
    );
  }
}

