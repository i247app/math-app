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

  int get answeredCount => answeredQuestionIndexes.length;

  int get correctCount =>
      answeredQuestionIndexes.where(correctQuestionIndexes.contains).length;

  int get wrongCount => answeredQuestionIndexes
      .where((index) => !correctQuestionIndexes.contains(index))
      .length;

  bool get isComplete {
    return totalQuestions > 0 &&
        answeredQuestionIndexes.length >= totalQuestions;
  }

  bool get passed => isComplete && wrongCount * 2 < totalQuestions;

  bool get failed => isComplete && !passed;

  bool get isExactlyFiftyPercent {
    return isComplete && wrongCount * 2 == totalQuestions;
  }

  int wrongCountInFirstQuestions(int count) {
    return answeredQuestionIndexes
        .where(
          (index) =>
              index >= 0 &&
              index < count &&
              !correctQuestionIndexes.contains(index),
        )
        .length;
  }

  bool areFirstQuestionsAnswered(int count) {
    if (totalQuestions < count || count <= 0) {
      return false;
    }
    for (var index = 0; index < count; index++) {
      if (!answeredQuestionIndexes.contains(index)) {
        return false;
      }
    }
    return true;
  }

  bool areFirstQuestionsPerfect(int count) {
    return areFirstQuestionsAnswered(count) &&
        wrongCountInFirstQuestions(count) == 0;
  }

  bool areFirstQuestionsWrong(int count) {
    return areFirstQuestionsAnswered(count) &&
        wrongCountInFirstQuestions(count) == count;
  }

  bool isQuestionWrong(int index) {
    return answeredQuestionIndexes.contains(index) &&
        !correctQuestionIndexes.contains(index);
  }

  bool get requiredQuestionsAreCorrect {
    return answeredQuestionIndexes.contains(2) &&
        answeredQuestionIndexes.contains(5) &&
        !isQuestionWrong(2) &&
        !isQuestionWrong(5);
  }

  bool get hasWrongRequiredQuestion {
    return isQuestionWrong(2) || isQuestionWrong(5);
  }

  bool get canUpgradeOneGrade {
    return isComplete &&
        wrongCount * 2 <= totalQuestions &&
        requiredQuestionsAreCorrect;
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
  static const int earlyFailQuestionCount = 5;

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
    if (score.areFirstQuestionsWrong(earlyFailQuestionCount)) {
      return _downgradeEarly(state);
    }

    final firstSixCorrect = score.areFirstQuestionsPerfect(
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

    if (score.isExactlyFiftyPercent && score.hasWrongRequiredQuestion) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
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
    if (score.canUpgradeOneGrade) {
      return _upgradeOrSubmit(
        state,
        gradeIncrease: 1,
        nextMode: AssessmentFlowMode.normal,
      );
    }
    if (score.passed) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _failNormalSet(state);
  }

  static AssessmentFlowDecision _finishRecoverySet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.canUpgradeOneGrade) {
      return _upgradeOrSubmit(
        state,
        gradeIncrease: 1,
        nextMode: AssessmentFlowMode.verification,
      );
    }
    if (score.passed) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _failRecoverySet(state);
  }

  static AssessmentFlowDecision _finishVerificationSet(
    AssessmentFlowState state,
    AssessmentSetScore score,
  ) {
    if (score.failed) {
      return _failVerificationSet(state);
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
    return _failDowngradeSet(state);
  }

  static AssessmentFlowDecision _downgradeEarly(AssessmentFlowState state) {
    return switch (state.mode) {
      AssessmentFlowMode.normal => _failNormalSet(state),
      AssessmentFlowMode.recovery => _failRecoverySet(state),
      AssessmentFlowMode.verification => _failVerificationSet(state),
      AssessmentFlowMode.downgrade => _failDowngradeSet(state),
    };
  }

  static AssessmentFlowDecision _failNormalSet(AssessmentFlowState state) {
    final failedState = state.copyWith(isFailed: true);
    return _generate(
      failedState,
      grade: state.grade == minimumGrade ? state.grade : state.grade - 1,
      mode: AssessmentFlowMode.recovery,
    );
  }

  static AssessmentFlowDecision _failRecoverySet(AssessmentFlowState state) {
    if (state.grade == minimumGrade) {
      return AssessmentFlowDecision(AssessmentFlowAction.submit, state);
    }
    return _generate(
      state,
      grade: state.grade - 1,
      mode: AssessmentFlowMode.downgrade,
    );
  }

  static AssessmentFlowDecision _failVerificationSet(
    AssessmentFlowState state,
  ) {
    return AssessmentFlowDecision(
      AssessmentFlowAction.submit,
      state.copyWith(grade: clampGrade(state.grade - 1)),
    );
  }

  static AssessmentFlowDecision _failDowngradeSet(AssessmentFlowState state) {
    if (state.grade == minimumGrade) {
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
