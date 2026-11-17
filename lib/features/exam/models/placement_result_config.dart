import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/exam/data/exam_service.dart';

enum PlacementResultGenerationAction {
  continueGrade(examTypeGrade, AppKeys.gradeResultNextLevel);

  const PlacementResultGenerationAction(this.examType, this.labelKey);

  final String examType;
  final String labelKey;
}

/// The presentation and available action for each placement-result exam type.
class PlacementResultConfig {
  const PlacementResultConfig._({
    required this.headingKey,
    this.headerTitleKey,
    this.showsGradeRibbon = true,
    this.showsAssessmentChart = false,
    this.showsGradeResult = false,
    this.generationAction,
  });

  final String headingKey;
  final String? headerTitleKey;
  final bool showsGradeRibbon;
  final bool showsAssessmentChart;
  final bool showsGradeResult;
  final PlacementResultGenerationAction? generationAction;

  static const _assessment = PlacementResultConfig._(
    headingKey: AppKeys.placementResultLevel,
    headerTitleKey: AppKeys.assessmentResultHeaderTitle,
    showsAssessmentChart: true,
  );
  static const _grade = PlacementResultConfig._(
    headingKey: AppKeys.placementResultGradeHeading,
    showsGradeRibbon: false,
    showsGradeResult: true,
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
