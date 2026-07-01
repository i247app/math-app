part of '../../presentation/assessment_result_screen.dart';

_ResultLevel _resultLevel(int score) {
  if (score >= 9) {
    return const _ResultLevel(
      titleKey: AppKeys.excellentResultTitle,
      color: _resultScoreGreen,
    );
  }
  if (score >= 7) {
    return const _ResultLevel(
      titleKey: AppKeys.goodResultTitle,
      color: _resultScoreYellow,
    );
  }
  if (score >= 5) {
    return const _ResultLevel(
      titleKey: AppKeys.completedResultTitle,
      color: _resultScoreOrange,
    );
  }
  return const _ResultLevel(
    titleKey: AppKeys.incompleteResultTitle,
    color: _resultScoreRed,
  );
}
