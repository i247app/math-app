import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/assessment_result_level.dart';
import 'package:numi_flutter/features/quiz/widgets/assessment_result/assessment_result_style.dart';

AssessmentResultLevel resultLevelForScore(int score) {
  if (score >= 9) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.excellentResultTitle,
      color: AssessmentResultStyle.scoreGreen,
    );
  }
  if (score >= 7) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.goodResultTitle,
      color: AssessmentResultStyle.scoreYellow,
    );
  }
  if (score >= 5) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.completedResultTitle,
      color: AssessmentResultStyle.scoreOrange,
    );
  }
  return const AssessmentResultLevel(
    titleKey: AppKeys.incompleteResultTitle,
    color: AssessmentResultStyle.scoreRed,
  );
}
