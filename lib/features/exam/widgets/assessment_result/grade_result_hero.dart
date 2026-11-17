import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/widgets/assessment_result/grade_result_level_transition.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_celebration_mascot.dart';
import 'package:numi/features/exam/widgets/assessment_result/placement_grade_title.dart';

class GradeResultHero extends StatelessWidget {
  const GradeResultHero({
    super.key,
    required this.grade,
    required this.level,
    required this.passed,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.compact,
  });
  final int grade;
  final int level;
  final bool passed;
  final int correctAnswers;
  final int wrongAnswers;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: compact ? 4 : 16),
        PlacementGradeTitle(grade: grade, compact: compact),
        SizedBox(height: compact ? 8 : 12),
        PlacementCelebrationMascot(size: compact ? 84 : 104),
        GradeResultLevelTransition(
          grade: grade,
          level: level,
          passed: passed,
          compact: compact,
        ),
        SizedBox(height: compact ? 20 : 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            key: const ValueKey('grade-result-answer-stats'),
            padding: EdgeInsets.symmetric(vertical: compact ? 10 : 14),
            decoration: BoxDecoration(
              color: isDark ? colors.surface : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.border.withValues(alpha: 0.65)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AnswerStat(
                    count: correctAnswers,
                    label: context.getText(AppKeys.gradeResultCorrect),
                    color: colors.brandStrong,
                    icon: Icons.assignment_outlined,
                    valueKey: const ValueKey('grade-result-correct-count'),
                  ),
                ),
                SizedBox(
                  height: 92,
                  child: VerticalDivider(width: 1, color: colors.border),
                ),
                Expanded(
                  child: _AnswerStat(
                    count: wrongAnswers,
                    label: context.getText(AppKeys.gradeResultWrong),
                    color: colors.error,
                    icon: Icons.cancel_outlined,
                    valueKey: const ValueKey('grade-result-wrong-count'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerStat extends StatelessWidget {
  const _AnswerStat({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    required this.valueKey,
  });
  final int count;
  final String label;
  final Color color;
  final IconData icon;
  final Key valueKey;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
        ),
        child: Icon(icon, size: 23, color: color),
      ),
      const SizedBox(height: 2),
      Text(
        '$count',
        key: valueKey,
        style: GoogleFonts.nunito(
          color: color,
          fontSize: 30,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 3),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: context.themeColors.textPrimary,
            fontSize: 14,
            height: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
