import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/home/widgets/parent_streak_day_state.dart';
import 'package:numi/features/home/parent/home/widgets/parent_streak_day.dart';

class ParentLearningStreakCard extends StatelessWidget {
  const ParentLearningStreakCard({
    super.key,
    required this.hasCompletedAssessment,
  });

  final bool hasCompletedAssessment;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final dayLabels = <String>[
      context.getText(AppKeys.parentWeekdaySun),
      context.getText(AppKeys.parentWeekdayMon),
      context.getText(AppKeys.parentWeekdayTue),
      context.getText(AppKeys.parentWeekdayWed),
      context.getText(AppKeys.parentWeekdayThu),
      context.getText(AppKeys.parentWeekdayFri),
      context.getText(AppKeys.parentWeekdaySat),
    ];
    final states = hasCompletedAssessment
        ? const <ParentStreakDayState>[
            ParentStreakDayState.done,
            ParentStreakDayState.done,
            ParentStreakDayState.done,
            ParentStreakDayState.current,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
          ]
        : const <ParentStreakDayState>[
            ParentStreakDayState.current,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
            ParentStreakDayState.upcoming,
          ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.getText(AppKeys.parentLearningStreak),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dayLabels.length,
              (index) => ParentStreakDay(
                label: dayLabels[index],
                state: states[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
