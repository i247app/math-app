import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_data.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_day.dart';

class LearningStreakCard extends StatelessWidget {
  const LearningStreakCard({super.key, required this.data});

  final LearningStreakData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            data.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in data.days) LearningStreakDay(data: day),
            ],
          ),
        ],
      ),
    );
  }
}
