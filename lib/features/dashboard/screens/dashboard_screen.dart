import 'package:flutter/material.dart';
import 'package:student_planner/features/dashboard/widgets/overview_cards_section.dart';
import 'package:student_planner/features/dashboard/widgets/todays_tasks_section.dart';
import 'package:student_planner/features/dashboard/widgets/upcoming_exams_section.dart';
import 'package:student_planner/theme/app_theme.dart';
import 'package:student_planner/theme/widgets/glass_container.dart';
import 'package:student_planner/theme/widgets/gradient_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
    appBar:   AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            fontSize: 25
          ),
        ),
      actions: [
        IconButton(
          onPressed: () {

          },
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Add task',
        ),
      ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Ali 👋',
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 34,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Let's stay productive today",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const OverviewCardsSection(),
                const SizedBox(height: 24),
                Text(
                  'Upcoming Exams',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const UpcomingExamsSection(),
                const SizedBox(height: 24),
                Text(
                  "Today's Tasks",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const TodaysTasksSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
