import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ExamReviewGradeLevelBadge extends StatelessWidget {
  const ExamReviewGradeLevelBadge({
    super.key,
    required this.grade,
    required this.level,
  });

  final int grade;
  final int level;
  static const textFontSize = 13.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final gradeLabel = grade == 0
        ? context.getText(AppKeys.gradeRoadmapKindergarten)
        : context.formatText(AppKeys.gradeRoadmapGrade, {'grade': grade});
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const ValueKey('exam-review-grade-level-badge'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: colors.brandStrong.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, color: colors.brandStrong, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.formatText(AppKeys.examReviewGradeLevelBadge, {
                  'grade': gradeLabel,
                  'level': level,
                }),
                style: GoogleFonts.andika(
                  color: colors.brandStrong,
                  fontSize: textFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
