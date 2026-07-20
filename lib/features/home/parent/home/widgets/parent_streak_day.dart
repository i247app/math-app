import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/home/widgets/parent_dashed_circle_painter.dart';
import 'package:numi/features/home/parent/home/widgets/parent_streak_day_state.dart';

class ParentStreakDay extends StatelessWidget {
  const ParentStreakDay({super.key, required this.label, required this.state});

  final String label;
  final ParentStreakDayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Column(
      spacing: 4,
      children: [
        Text(
          label,
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
          child: switch (state) {
            ParentStreakDayState.done => DecoratedBox(
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
            ParentStreakDayState.current => DecoratedBox(
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
            ParentStreakDayState.upcoming => CustomPaint(
              painter: ParentDashedCirclePainter(color: colors.borderStrong),
              child: Center(
                child: Text(
                  '5',
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
