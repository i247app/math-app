import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/exam/helpers/parent_assessment_display_helpers.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/shared/widgets/score_progress_ring.dart';

class ParentAssessmentScoreBadge extends StatelessWidget {
  const ParentAssessmentScoreBadge({
    super.key,
    required this.grade,
    this.examType,
  });

  final int? grade;
  final String? examType;

  @override
  Widget build(BuildContext context) {
    final color = switch (examType?.trim().toUpperCase()) {
      examTypeAssessment => AppColors.orange600,
      examTypeGrade => AppColors.brandTeal,
      _ => parentAssessmentGradeColor(grade),
    };
    return SizedBox(
      width: 56,
      child: ScoreProgressRing(
        progress: 1,
        color: color,
        trackColor: color,
        size: 48,
        strokeWidth: 5,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            grade?.toString() ?? '--',
            key: const ValueKey<String>('parent-assessment-grade-badge'),
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
