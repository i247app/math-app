import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_dashed_circle_painter.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_day_data.dart';
import 'package:numi/features/home/widgets/sections/learning_streak/learning_streak_day_state.dart';

class LearningStreakDay extends StatelessWidget {
  const LearningStreakDay({super.key, required this.data});

  final LearningStreakDayData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Column(
      spacing: 4,
      children: [
        Text(
          data.label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: FontSize.xxxs,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        SizedBox(
          width: 31,
          height: 31,
          child: switch (data.state) {
            LearningStreakDayState.done => DecoratedBox(
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: colors.onSuccess,
                size: 19,
              ),
            ),
            LearningStreakDayState.current => DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: colors.onAccent,
                size: 21,
              ),
            ),
            LearningStreakDayState.upcoming => CustomPaint(
              painter: LearningStreakDashedCirclePainter(
                color: colors.borderStrong,
              ),
              child: Center(
                child: Text(
                  data.upcomingValue,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: FontSize.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}
