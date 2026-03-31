import 'package:flutter/material.dart';
import 'package:student_planner/core/constants/app_colors.dart';
import 'package:student_planner/features/dashboard/widgets/overview_card_data.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({required this.data, super.key});

  final OverviewCardData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(data.icon, color: data.iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            data.value,
            style: textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 2),
          Text(data.label, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

