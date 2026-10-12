import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_typography.dart';
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
  static const textFontSize = FontSize.xs;

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
          color: colors.primaryAction.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded, color: colors.primaryAction, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.formatText(AppKeys.examReviewGradeLevelBadge, {
                  'grade': gradeLabel,
                  'level': level,
                }),
                style: (context.textStyles.bodyLarge ?? const TextStyle())
                    .copyWith(
                      color: colors.primaryAction,
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
