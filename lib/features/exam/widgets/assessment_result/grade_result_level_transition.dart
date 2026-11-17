import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';

/// Illustrates progress before and after the attempted level, starting at zero.
/// These markers are not navigation controls.
class GradeResultLevelTransition extends StatelessWidget {
  const GradeResultLevelTransition({
    super.key,
    required this.level,
    required this.passed,
    required this.compact,
  });
  final int level;
  final bool passed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final attemptedLevel = level.clamp(1, GradeExamFlowPolicy.maximumLevel);
    return SizedBox(
      key: const ValueKey('grade-result-level-transition'),
      height: compact ? 112 : 128,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _LevelMarker(
            key: const ValueKey('grade-result-current-level'),
            level: attemptedLevel - 1,
            size: compact ? 70 : 76,
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: CustomPaint(
              size: Size(compact ? 52 : 64, 44),
              painter: _LevelArrowPainter(
                colors.brandStrong.withValues(alpha: 0.45),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: compact ? 104 : 116,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _LevelMarker(
                  key: const ValueKey('grade-result-next-level'),
                  level: attemptedLevel,
                  size: compact ? 88 : 96,
                  locked: !passed,
                ),
                if (passed)
                  Positioned(
                    right: 0,
                    top: -18,
                    child: Transform.rotate(
                      angle: 0.35,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 28,
                        color: colors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelMarker extends StatelessWidget {
  const _LevelMarker({
    super.key,
    required this.level,
    required this.size,
    this.locked = false,
  });
  final int level;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = locked ? colors.textMuted : colors.brandStrong;
    final label = context.formatText(AppKeys.placementResultGradeLevel, {
      'level': level,
    });
    return Semantics(
      button: false,
      label: locked
          ? '$label, ${context.getText(AppKeys.gradeResultLocked)}'
          : label,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: locked
                ? (isDark ? colors.surface : const Color(0xFFEEF0F2))
                : (isDark ? colors.infoSurface : const Color(0xFFE1F6F2)),
            border: Border.all(
              color: foreground.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: foreground.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (locked)
                Icon(
                  Icons.lock_rounded,
                  key: const ValueKey('grade-result-next-level-lock'),
                  size: 22,
                  color: foreground,
                )
              else
                Text(
                  context.getText(AppKeys.gradeResultLevelLabel),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: foreground,
                    height: 1.1,
                  ),
                ),
              Text(
                '$level',
                style: GoogleFonts.nunito(
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w900,
                  color: foreground,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelArrowPainter extends CustomPainter {
  const _LevelArrowPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(3, size.height - 4)
        ..quadraticBezierTo(size.width * 0.45, 5, size.width - 5, 10),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 17, 2)
        ..lineTo(size.width - 4, 10)
        ..lineTo(size.width - 12, 23),
      paint,
    );
  }

  @override
  bool shouldRepaint(_LevelArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}
