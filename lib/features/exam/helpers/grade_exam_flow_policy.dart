import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';

class GradeExamOutcome {
  const GradeExamOutcome({
    required this.progress,
    required this.passed,
    required this.levelIncrease,
  });

  final ProfileGradeProgress progress;
  final bool passed;
  final int levelIncrease;
}

/// One-set placement policy for a GRADE exam.
///
/// It reuses the assessment signals, but never generates another set:
/// First six correct or a completed set with at least 50% advances one level.
/// Failed attempts leave progress unchanged until a server policy is available.
class GradeExamFlowPolicy {
  const GradeExamFlowPolicy._();

  static const int minimumLevel = 0;
  static const int defaultLevel = 1;
  static const int maximumLevel = 10;

  static GradeExamOutcome evaluate({
    required int attemptedGrade,
    required int attemptedLevel,
    required AssessmentSetScore score,
    required ProfileGradeProgress savedProgress,
  }) {
    final normalizedAttempt = ProfileGradeProgress(
      grade: AssessmentFlowPolicy.clampGrade(attemptedGrade),
      level: attemptedLevel.clamp(minimumLevel, maximumLevel),
    );
    final isHistoricalAttempt =
        normalizedAttempt.sortValue < savedProgress.sortValue;
    final failedFirstFive = score.areFirstQuestionsWrong(
      AssessmentFlowPolicy.earlyFailQuestionCount,
    );
    final firstSixPerfect = score.areFirstQuestionsPerfect(
      AssessmentFlowPolicy.firstQuestionsUpgradeTarget,
    );
    if (firstSixPerfect) {
      final achieved = _advance(normalizedAttempt, 1);
      return GradeExamOutcome(
        progress: isHistoricalAttempt
            ? savedProgress
            : achieved.isHigherThan(savedProgress)
            ? achieved
            : savedProgress,
        passed: true,
        levelIncrease: 1,
      );
    }
    final reachedFiftyPercent =
        score.isComplete && score.correctCount * 2 >= score.totalQuestions;
    if (failedFirstFive || !reachedFiftyPercent) {
      // TODO: Apply the future API policy for downgrade-rule outcomes here.
      return GradeExamOutcome(
        progress: savedProgress,
        passed: false,
        levelIncrease: 0,
      );
    }

    const levelIncrease = 1;
    final achieved = _advance(normalizedAttempt, levelIncrease);
    return GradeExamOutcome(
      progress: isHistoricalAttempt
          ? savedProgress
          : achieved.isHigherThan(savedProgress)
          ? achieved
          : savedProgress,
      passed: true,
      levelIncrease: levelIncrease,
    );
  }

  static int levelForSelectedGrade({
    required int selectedGrade,
    required ProfileGradeProgress savedProgress,
  }) {
    if (selectedGrade == savedProgress.grade &&
        (savedProgress.grade > 0 || savedProgress.level > 0)) {
      return savedProgress.level.clamp(minimumLevel, maximumLevel);
    }
    return defaultLevel;
  }

  static ProfileGradeProgress _advance(
    ProfileGradeProgress progress,
    int levelIncrease,
  ) {
    var grade = progress.grade;
    var level = progress.level + levelIncrease;
    while (level > maximumLevel && grade < AssessmentFlowPolicy.maximumGrade) {
      grade++;
      level -= maximumLevel;
    }
    if (grade == AssessmentFlowPolicy.maximumGrade && level > maximumLevel) {
      level = maximumLevel;
    }
    return ProfileGradeProgress(grade: grade, level: level);
  }
}
