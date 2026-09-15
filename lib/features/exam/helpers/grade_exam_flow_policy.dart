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
/// first six correct advances two levels; at least 50% with question 3 or 6
/// correct advances one level; a pass without an anchor keeps the attempted
/// level. A failed attempt never lowers the profile's saved progress.
class GradeExamFlowPolicy {
  const GradeExamFlowPolicy._();

  static const int minimumLevel = 1;
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
    final failedFirstFive = score.areFirstQuestionsWrong(
      AssessmentFlowPolicy.earlyFailQuestionCount,
    );
    final reachedFiftyPercent =
        score.isComplete && score.correctCount * 2 >= score.totalQuestions;
    if (failedFirstFive || !reachedFiftyPercent) {
      return GradeExamOutcome(
        progress: savedProgress,
        passed: false,
        levelIncrease: 0,
      );
    }

    final levelIncrease =
        score.areFirstQuestionsPerfect(
          AssessmentFlowPolicy.firstQuestionsUpgradeTarget,
        )
        ? 2
        : score.hasUpgradeAnchorQuestionCorrect
        ? 1
        : 0;
    final achieved = _advance(normalizedAttempt, levelIncrease);
    return GradeExamOutcome(
      progress: achieved.isHigherThan(savedProgress) ? achieved : savedProgress,
      passed: true,
      levelIncrease: levelIncrease,
    );
  }

  static int levelForSelectedGrade({
    required int selectedGrade,
    required ProfileGradeProgress savedProgress,
  }) {
    if (selectedGrade == savedProgress.grade && savedProgress.level > 0) {
      return savedProgress.level.clamp(minimumLevel, maximumLevel);
    }
    return minimumLevel;
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
