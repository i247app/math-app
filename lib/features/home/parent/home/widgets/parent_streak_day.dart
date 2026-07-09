import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/parent/home/widgets/parent_dashed_circle_painter.dart';
import 'package:numi/features/home/parent/home/widgets/parent_streak_day_state.dart';

class ParentStreakDay extends StatelessWidget {
  const ParentStreakDay({required this.label, required this.state});

  final String label;
  final ParentStreakDayState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9A6B61),
            fontSize: FontSize.caption * 0.77,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 31,
          height: 31,
          child: switch (state) {
            ParentStreakDayState.done => const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF4FB465),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 19),
            ),
            ParentStreakDayState.current => const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFF5F19),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            ParentStreakDayState.upcoming => const CustomPaint(
              painter: ParentDashedCirclePainter(),
              child: Center(
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Color(0xFFC98E7E),
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
