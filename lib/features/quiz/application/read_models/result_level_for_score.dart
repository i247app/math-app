import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/quiz/presentation/widgets/assessment_result/assessment_result_level.dart';
import 'package:numi/core/theme/app_colors.dart';

AssessmentResultLevel resultLevelForScore(int score) {
  if (score >= 9) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.excellentResultTitle,
      color: AppColors.scoreGreen,
    );
  }
  if (score >= 7) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.goodResultTitle,
      color: AppColors.scoreYellow,
    );
  }
  if (score >= 5) {
    return const AssessmentResultLevel(
      titleKey: AppKeys.completedResultTitle,
      color: AppColors.orange600,
    );
  }
  return const AssessmentResultLevel(
    titleKey: AppKeys.incompleteResultTitle,
    color: AppColors.red700,
  );
}
