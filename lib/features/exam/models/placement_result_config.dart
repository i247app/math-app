import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/data/exam_service.dart';

enum PlacementResultRibbon { assessmentGrade, gradeLevel }

enum PlacementResultGenerationAction {
  continueGrade(examTypeGrade, AppKeys.placementResultNext);

  const PlacementResultGenerationAction(this.examType, this.labelKey);

  final String examType;
  final String labelKey;
}

/// The presentation and available action for each placement-result exam type.
class PlacementResultConfig {
  const PlacementResultConfig._({
    required this.headingKey,
    this.headerTitleKey,
    this.ribbon = PlacementResultRibbon.assessmentGrade,
    this.showsAssessmentChart = false,
    this.generationAction,
  });

  final String headingKey;
  final String? headerTitleKey;
  final PlacementResultRibbon ribbon;
  final bool showsAssessmentChart;
  final PlacementResultGenerationAction? generationAction;

  static const _assessment = PlacementResultConfig._(
    headingKey: AppKeys.placementResultLevel,
    headerTitleKey: AppKeys.assessmentResultHeaderTitle,
    showsAssessmentChart: true,
  );
  static const _grade = PlacementResultConfig._(
    headingKey: AppKeys.placementResultGradeHeading,
    ribbon: PlacementResultRibbon.gradeLevel,
    generationAction: PlacementResultGenerationAction.continueGrade,
  );
  static const _other = PlacementResultConfig._(
    headingKey: AppKeys.placementResultLevel,
  );

  static PlacementResultConfig forExamType(String examType) {
    return switch (examType.trim().toUpperCase()) {
      examTypeAssessment => _assessment,
      examTypeGrade => _grade,
      _ => _other,
    };
  }
}
