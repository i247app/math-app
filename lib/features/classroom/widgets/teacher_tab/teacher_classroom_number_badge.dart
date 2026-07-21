import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/features/classroom/widgets/teacher_tab/teacher_classroom_number_helpers.dart';

class TeacherClassroomNumberBadge extends StatelessWidget {
  const TeacherClassroomNumberBadge({
    super.key,
    required this.number,
    required this.palette,
  });
  final String number;
  final TeacherClassroomNumberPalette palette;

  TextStyle get _numberStyle => const TextStyle(
    fontSize: FontSize.displayHero,
    fontWeight: FontWeight.w900,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    const radius = 16.0;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.45, -0.5),
                  radius: 1.05,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    palette.background,
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(3.5, 5.5),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: palette.shadow),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 3),
            child: Text(
              number,
              style: _numberStyle.copyWith(
                color: palette.depth,
                shadows: [
                  Shadow(
                    color: palette.shadow,
                    offset: const Offset(2, 2.6),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.top, palette.bottom],
              stops: const [0.12, 0.88],
            ).createShader(bounds),
            child: Text(
              number,
              style: _numberStyle.copyWith(color: Colors.white),
            ),
          ),
          Positioned(
            top: 17,
            left: 26,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 13,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
