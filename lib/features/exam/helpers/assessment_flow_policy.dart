/// The adaptive assessment phase currently being evaluated.
enum AssessmentFlowMode { normal, recovery, verification, downgrade }

enum AssessmentFlowAction { continueSet, generateSet, submit }

class AssessmentFlowState {
  const AssessmentFlowState({
    required this.grade,
    this.mode = AssessmentFlowMode.normal,
    this.isFailed = false,
    this.setNumber = 1,
  });

  final int grade;
  final AssessmentFlowMode mode;
  final bool isFailed;
  final int setNumber;

  AssessmentFlowState copyWith({
    int? grade,
    AssessmentFlowMode? mode,
    bool? isFailed,
    int? setNumber,
  }) {
    return AssessmentFlowState(
      grade: grade ?? this.grade,
      mode: mode ?? this.mode,
      isFailed: isFailed ?? this.isFailed,
      setNumber: setNumber ?? this.setNumber,
    );
  }
}

class AssessmentSetScore {
  AssessmentSetScore({
    required this.totalQuestions,
    required Set<int> answeredQuestionIndexes,
    required Set<int> correctQuestionIndexes,
  }) : answeredQuestionIndexes = Set<int>.unmodifiable(answeredQuestionIndexes),
       correctQuestionIndexes = Set<int>.unmodifiable(correctQuestionIndexes);

  final int totalQuestions;
  final Set<int> answeredQuestionIndexes;
  final Set<int> correctQuestionIndexes;

  int get correctCount => correctQuestionIndexes.length;

  bool get isComplete {
    return totalQuestions > 0 &&
        answeredQuestionIndexes.length >= totalQuestions;
  }

  bool get passed => correctCount * 2 > totalQuestions;

  bool get failed => isComplete && !passed;

  bool areFirstQuestionsCorrect(int count) {
    if (totalQuestions < count) {
      return false;
    }
    for (var index = 0; index < count; index++) {
      if (!correctQuestionIndexes.contains(index)) {
        return false;
      }
    }
    return true;
  }

  bool get questionThreeAndSixCorrect {
    return correctQuestionIndexes.contains(2) &&
        correctQuestionIndexes.contains(5);
  }

  bool get qualifiesForSingleGradeUpgrade {
    return totalQuestions > 0 &&
        correctCount * 2 >= totalQuestions &&
        questionThreeAndSixCorrect;
  }
}

class AssessmentFlowDecision {
  const AssessmentFlowDecision(this.action, this.nextState);

  final AssessmentFlowAction action;
  final AssessmentFlowState nextState;
}

/// Pure decision policy for a sequence of generated 10-question sets.
///
/// Keeping grade/set decisions here makes the API controller responsible only
/// for generating, activating the next set, and submitting the final set.
class AssessmentFlowPolicy {
  const AssessmentFlowPolicy._();

  static const int minimumGrade = 0;
  static const int maximumGrade = 5;
  static const int generatedQuestionCount = 10;
  static const int firstQuestionsUpgradeTarget = 6;

  static int clampGrade(int grade) {
    return grade.clamp(minimumGrade, maximumGrade);
  }

  static int gradeFromLabel(String? label, {int fallback = minimumGrade}) {
    final normalized = label?.trim().toLowerCase() ?? '';
    if (normalized.contains('mẫu giáo') ||
        normalized.contains('mau giao') ||
        normalized.contains('kindergarten')) {
      return minimumGrade;
    }

    final match = RegExp(r'\d+').firstMatch(normalized);
    final parsed = int.tryParse(match?.group(0) ?? '');
    return clampGrade(parsed ?? fallback);
  }

  static String gradeLabel(int grade) {
    final normalizedGrade = clampGrade(grade);
    return normalizedGrade == minimumGrade
        ? 'Mẫu giáo'
        : 'Lớp $normalizedGrade';
  }

  static AssessmentFlowDecision decide(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    final firstSixCorrect = score.areFirstQuestionsCorrect(
      firstQuestionsUpgradeTarget,
    );

    if (firstSixCorrect) {
      if (state.mode == AssessmentFlowMode.normal) {
        return _upgradeOrSubmit(
          state,
          gradeIncrease: 2,
          nextMode: AssessmentFlowMode.normal,
        );
      }
      if (state.mode == AssessmentFlowMode.recovery) {
        return _upgradeOrSubmit(
          state,
          gradeIncrease: 1,
          nextMode: AssessmentFlowMode.verification,
        );
      }
    }

    if (!score.isComplete) {
      return AssessmentFlowDecision(AssessmentFlowAction.continueSet, state);
    }

    return switch (state.mode) {
      AssessmentFlowMode.normal => _finishNormalSet(state, score),
      AssessmentFlowMode.recovery => _finishRecoverySet(state, score),
      AssessmentFlowMode.verification => _finishVerificationSet(state, score),
      AssessmentFlowMode.downgrade => _finishDowngradeSet(state, score),
    };
  }

  static AssessmentFlowDecision _finishNormalSet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.qualifiesForSingleGradeUpgrade) {
      return _upgradeOrSubmit(
        state,
        gradeIncrease: 1,
        nextMode: AssessmentFlowMode.normal,
      );
    }
    if (score.passed) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }

    final failedState = state.copyWith(isFailed: true);
    if (state.grade == minimumGrade) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, failedState);
    }
    return _generate(
      failedState,
      grade: state.grade - 1,
      mode: AssessmentFlowMode.recovery,
    );
  }

  static AssessmentFlowDecision _finishRecoverySet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.qualifiesForSingleGradeUpgrade) {
      return _upgradeOrSubmit(
        state,
        gradeIncrease: 1,
        nextMode: AssessmentFlowMode.verification,
      );
    }
    if (score.passed) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    if (state.grade == minimumGrade) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _generate(
      state,
      grade: state.grade - 1,
      mode: AssessmentFlowMode.downgrade,
    );
  }

  static AssessmentFlowDecision _finishVerificationSet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.failed) {
      return AssessmentFlowDecision(
        AssessmentFlowAction.submit,
        state.copyWith(grade: clampGrade(state.grade - 1)),
      );
    }
    return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
  }

  static AssessmentFlowDecision _finishDowngradeSet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.passed || state.grade == minimumGrade) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _generate(
      state,
      grade: state.grade - 1,
      mode: AssessmentFlowMode.downgrade,
    );
  }

  static AssessmentFlowDecision _upgradeOrSubmit(
    AssessmentFlowState state, {
    required int gradeIncrease,
    required AssessmentFlowMode nextMode,
  }) {
    if (state.grade >= maximumGrade) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _generate(state, grade: state.grade + gradeIncrease, mode: nextMode);
  }

  static AssessmentFlowDecision _generate(
    AssessmentFlowState state, {
    required int grade,
    required AssessmentFlowMode mode,
  }) {
    return AssessmentFlowDecision(
      AssessmentFlowAction.generateSet,
      state.copyWith(
        grade: clampGrade(grade),
        mode: mode,
        setNumber: state.setNumber + 1,
      ),
    );
  }
}
