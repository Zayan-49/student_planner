import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:student_planner/data/models/task.dart';
import 'package:student_planner/data/services/task_hive_service.dart';
import 'package:student_planner/features/dashboard/widgets/overview_card.dart';
import 'package:student_planner/features/dashboard/widgets/overview_card_data.dart';
import 'package:student_planner/theme/app_theme.dart';

class OverviewCardsSection extends StatelessWidget {
  const OverviewCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskHiveService.instance;

    return ValueListenableBuilder<Box<Task>>(
      valueListenable: taskService.listenable(),
      builder: (context, _, child) {
        final cards = [
          OverviewCardData(
            icon: Icons.check_circle_outline_rounded,
            iconBackgroundColor: const Color(0x3322C55E),
            iconColor: AppTheme.secondary,
            value: taskService.getTodayTaskCount().toString(),
            label: 'Tasks Today',
          ),
          OverviewCardData(
            icon: Icons.task_alt_rounded,
            iconBackgroundColor: const Color(0x3310B981),
            iconColor: AppTheme.primary,
            value: taskService.getCompletedTaskCount().toString(),
            label: 'Completed',
          ),
           OverviewCardData(
            icon: Icons.calendar_today_rounded,
            iconBackgroundColor: Color(0x33F59E0B),
            iconColor: Color(0xFFF59E0B),
            value: '2',
            label: 'Upcoming Exams',
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 680;
            if (isNarrow) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    Expanded(child: OverviewCard(data: cards[i])),
                    if (i != cards.length - 1)
                      const SizedBox(width: 12, height: 12),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  Expanded(child: OverviewCard(data: cards[i])),
                  if (i != cards.length - 1)
                    const SizedBox(width: 12, height: 12),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
