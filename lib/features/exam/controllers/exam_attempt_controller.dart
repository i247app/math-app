import 'package:numi/features/exam/data/exam_image_refresher.dart';
import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/controllers/exam_attempt_flow.dart';
import 'package:numi/features/exam/data/exam_attempt_requests.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_attempt_answers.dart';
import 'package:numi/features/exam/models/exam_attempt_state.dart';

export 'package:numi/features/exam/models/exam_attempt_state.dart';

const assessmentCorrectAnswerTarget =
    AssessmentFlowPolicy.firstQuestionsUpgradeTarget;

/// UI-facing facade for answer state, mode policies and asynchronous set work.
class ExamAttemptController extends ChangeNotifier {
  ExamAttemptController({
    required ExamService examService,
    GeneratedExam? initialExam,
    this.examType = examTypeAssessment,
    this.gradeLabel,
    this.level,
    this.profileId,
    this.startAtKindergarten = true,
  }) : _exam = initialExam {
    _flow = ExamAttemptFlow(
      kind: _kind,
      initialExam: initialExam,
      gradeLabel: gradeLabel,
      level: level,
    );
    _requests = ExamAttemptRequests(
      service: examService,
      examType: examType,
      profileId: profileId,
    );
    _questionIndex = _answers.restore(initialExam);
    _imageRefresher = ExamImageRefresher(
      load: (source) => examService.getExamDetail(
        source.examId!,
        profileId: profileId ?? source.profileId,
        examType: source.examType ?? examType,
      ),
      isCurrent: (source) =>
          !_disposed && _requests.isActive && identical(_exam, source),
      apply: (fresh) {
        _exam = fresh;
        notifyListeners();
      },
    );
    _imageRefresher.schedule(initialExam);
    if (initialExam != null && initialExam.questions.isEmpty) {
      _needsNewPaper = true;
      _errorMessage = AppStrings.current(AppKeys.examPaperUnavailable);
      _errorRetryAction = ExamAttemptRetryAction.generate;
    }
  }

  final String examType;
  final String? gradeLabel;
  final int? level;
  final int? profileId;
  final bool startAtKindergarten;
  final _answers = ExamAttemptAnswers();
  late final ExamAttemptFlow _flow;
  late final ExamAttemptRequests _requests;
  late final ExamImageRefresher _imageRefresher;
  int? _errorStatus;
  bool get hasRecoverablePaperError => _needsNewPaper || _errorStatus == 13747;
  bool _needsNewPaper = false;
  bool get needsNewPaper => _needsNewPaper;
  GeneratedExam? _exam;
  int _questionIndex = 0;
  String? _errorMessage;
  ExamAttemptRetryAction? _errorRetryAction;
  bool _isGeneratingExam = false;
  bool _isTransitioningSet = false;
  bool _isSubmittingExam = false;
  bool _isUpdatingExitStatus = false;
  int _operationRevision = 0;
  bool _disposed = false;

  ExamAttemptKind get _kind =>
      ExamAttemptKind.fromType(_exam?.examType ?? examType);
  bool get _isAssessment => _kind == ExamAttemptKind.assessment;
  bool get _isPractice => _kind == ExamAttemptKind.practice;
  bool get _isGrade => _kind == ExamAttemptKind.grade;
  bool _canApply(int revision) =>
      !_disposed && revision == _operationRevision && _requests.isActive;

  ExamService get examService => _requests.service;
  GeneratedExam? get exam => _exam;
  bool get isAssessment => _isAssessment;
  bool get isPractice => _isPractice;
  bool get isGrade => _isGrade;
  int get questionIndex => _questionIndex;
  int get questionNumberOffset => _flow.questionNumberOffset;
  int get progressQuestionIndex => _isTransitioningSet ? 1 : _questionIndex + 1;
  int get progressQuestionNumberOffset =>
      _flow.questionNumberOffset +
      (_isTransitioningSet ? _answers.answeredCount : 0);
  int get displayedQuestionNumber =>
      progressQuestionNumberOffset + progressQuestionIndex;
  int get currentGrade => _flow.state.grade;
  int get currentLevel => _flow.currentLevel;
  String get currentGradeLabel => AssessmentFlowPolicy.gradeLabel(currentGrade);
  int get setNumber => _flow.state.setNumber;
  AssessmentFlowMode get flowMode => _flow.state.mode;
  bool get isFailed => _flow.state.isFailed;
  List<AssessmentSetRecord> get completedSets => _flow.completedSets;
  Map<int, String> get selectedAnswerLabels => _answers.firstAttempts;
  String? get errorMessage => _errorMessage;
  ExamAttemptRetryAction? get errorRetryAction => _errorRetryAction;
  bool get isGeneratingExam => _isGeneratingExam || _isTransitioningSet;
  bool get isTransitioningSet => _isTransitioningSet;
  int? get transitioningGradeDelta {
    final decision = _flow.pendingDecision;
    if (!_isAssessment || !_isTransitioningSet || decision == null) return null;
    return decision.nextState.grade - currentGrade;
  }

  bool get isTransitioningToHigherGrade => (transitioningGradeDelta ?? 0) > 0;
  bool get isSubmittingExam => _isSubmittingExam;
  int? get userExamId {
    final current = _exam?.userExamId;
    if (current != null && current > 0) return current;
    final submitted = _requests.latestUserExamId;
    if (submitted != null) return submitted;
    for (final set in completedSets.reversed) {
      final id = set.exam.userExamId;
      if (id != null && id > 0) return id;
    }
    return null;
  }

  ExamQuestion? get currentQuestion {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    return _questionIndex >= questions.length
        ? null
        : questions[_questionIndex];
  }

  String? get selectedAnswerLabel =>
      _answers.selectedLabel(_questionIndex, practice: _isPractice);
  bool? get selectedAnswerFeedbackCorrect =>
      _isPractice ? _answers.feedbackAt(_questionIndex) : null;
  Set<String> get selectedOptionIds =>
      _answers
          .selected(_questionIndex, practice: _isPractice)
          ?.optionIds
          .toSet() ??
      const {};
  String get numericValue =>
      _answers.selected(_questionIndex, practice: _isPractice)?.value ?? '';
  bool get canContinue =>
      _answers.selected(_questionIndex, practice: _isPractice)?.isValid == true;
  int? get firstUnansweredQuestionIndex =>
      _answers.firstUnansweredIndex(_exam?.questions ?? const []);
  bool get allQuestionsAnswered =>
      (_exam?.questions.isNotEmpty ?? false) &&
      firstUnansweredQuestionIndex == null;
  AssessmentSetScore get _currentSetScore => _answers.score(_exam);
  int get correctAnswerCount => _currentSetScore.correctCount;
  int get totalCorrectAnswerCount =>
      completedSets.fold<int>(
        0,
        (total, set) => total + set.correctAnswerCount,
      ) +
      correctAnswerCount;
  int get totalAnsweredQuestionCount =>
      completedSets.fold<int>(
        0,
        (total, set) => total + set.selectedAnswerLabels.length,
      ) +
      _answers.answeredCount;
  bool get shouldAutoSubmitAssessment => _flow.allowsPartialSubmit;
  bool? get isSelectedAnswerCorrect => _answers.selectedIsCorrect(
    currentQuestion,
    _questionIndex,
    practice: _isPractice,
  );
  bool? isAnswerCorrect(ExamAnswer answer) {
    final question = currentQuestion;
    return question == null
        ? null
        : ExamAttemptAnswers.isAnswerCorrect(question, answer);
  }

  bool get isGeneratingQuestion =>
      (_isGeneratingExam || currentQuestion == null) && _errorMessage == null;
  bool get isLastQuestion =>
      _questionIndex >= (_exam?.questions.length ?? 0) - 1;

  Future<void> updateCurrentUserExamStatus(String status) async {
    final id = userExamId;
    if (id == null) {
      throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
    }
    await _requests.updateStatus(
      userExamId: id,
      status: status,
      fallbackProfileId: _exam?.profileId,
    );
  }

  Future<void> updateStatusForExit(String status) async {
    if (_isSubmittingExam || _isUpdatingExitStatus) {
      throw ExamException(
        AppStrings.current(AppKeys.assessmentStatusUpdateFailed),
      );
    }
    _isUpdatingExitStatus = true;
    try {
      await _requests.updateStatus(
        userExamId: userExamId,
        status: status,
        fallbackProfileId: _exam?.profileId,
      );
    } finally {
      _isUpdatingExitStatus = false;
    }
  }

  Future<bool> generateExam() async {
    if (_disposed ||
        !_requests.isActive ||
        _isGeneratingExam ||
        _isTransitioningSet) {
      return false;
    }
    final revision = ++_operationRevision;
    final kind = _kind;
    final initialGrade = _isAssessment && startAtKindergarten
        ? AssessmentFlowPolicy.minimumGrade
        : AssessmentFlowPolicy.gradeFromLabel(
            gradeLabel,
            fallback: _isAssessment ? 0 : 1,
          );
    _flow.reset(grade: initialGrade, level: level ?? 1, kind: kind);
    _requests.reset();
    _answers.clear();
    _exam = null;
    _needsNewPaper = false;
    _errorStatus = null;
    _imageRefresher.schedule(null);
    _questionIndex = 0;
    _errorMessage = null;
    _errorRetryAction = null;
    _isGeneratingExam = true;
    _isSubmittingExam = false;
    notifyListeners();
    final result = await _requests.generate(
      gradeLabel: _isAssessment && startAtKindergarten
          ? AssessmentFlowPolicy.gradeLabel(initialGrade)
          : gradeLabel,
      level: currentLevel,
    );
    if (!_canApply(revision)) return false;
    final generated = result.exam;
    _isGeneratingExam = false;
    if (generated == null) {
      _errorMessage = result.errorMessage;
      _errorStatus = result.errorStatus;
      _needsNewPaper = result.errorStatus == 13713;
      _errorRetryAction = ExamAttemptRetryAction.generate;
    } else {
      _exam = generated;
      _imageRefresher.schedule(generated);
      _questionIndex = _answers.restore(generated);
      _flow.restoreGenerated(generated, _kind);
    }
    notifyListeners();
    return generated != null;
  }

  Future<bool> retryGeneration() {
    if (_needsNewPaper) return generateExam();
    final decision = _flow.pendingDecision;
    return decision == null ? generateExam() : _transitionToNextSet(decision);
  }

  void selectAnswer(ExamAnswer answer) {
    if (_disposed || _isTransitioningSet || _isSubmittingExam) return;
    if (!_answers.select(
      _questionIndex,
      currentQuestion,
      answer,
      practice: _isPractice,
    )) {
      return;
    }
    _flow.selectionChanged();
    notifyListeners();
  }

  void setNumericValue(String value) {
    if (_disposed || _isTransitioningSet || _isSubmittingExam) return;
    final question = currentQuestion;
    if (question == null || !question.isNumericInput) return;
    _answers.setNumericValue(
      _questionIndex,
      question,
      value,
      practice: _isPractice,
    );
    _flow.selectionChanged();
    notifyListeners();
  }

  void clearPracticeFeedback({int? questionIndex}) {
    if (_disposed ||
        !_isPractice ||
        !_answers.clearFeedback(questionIndex ?? _questionIndex)) {
      return;
    }
    notifyListeners();
  }

  AssessmentFlowAction preparePracticeFlow() {
    if (!_isPractice ||
        _isTransitioningSet ||
        _isSubmittingExam ||
        !canContinue) {
      return AssessmentFlowAction.continueSet;
    }
    _answers.commitPractice(_questionIndex);
    return _prepareSubmit();
  }

  GradeExamOutcome gradeOutcome(ProfileGradeProgress savedProgress) =>
      _flow.gradeOutcome(_currentSetScore, savedProgress);
  bool get shouldSubmitGrade =>
      _isGrade && _flow.shouldSubmitGrade(_currentSetScore);
  AssessmentFlowAction prepareGradeFlow() {
    if (!shouldSubmitGrade || _isSubmittingExam || _isTransitioningSet) {
      return AssessmentFlowAction.continueSet;
    }
    return _prepareSubmit();
  }

  AssessmentFlowAction _prepareSubmit() {
    final action = _flow.prepareSubmit(_kind, _currentSetScore);
    if (action == AssessmentFlowAction.submit) notifyListeners();
    return action;
  }

  Future<AssessmentFlowAction> advanceAssessmentFlow() async {
    if (!_isAssessment ||
        _isTransitioningSet ||
        _isSubmittingExam ||
        !canContinue) {
      return AssessmentFlowAction.continueSet;
    }
    final score = _currentSetScore;
    final decision = _flow.assessmentDecision(score);
    if (decision.action == AssessmentFlowAction.continueSet) {
      return decision.action;
    }
    if (decision.action == AssessmentFlowAction.submit) {
      _flow.applySubmit(decision, score);
      notifyListeners();
      return decision.action;
    }
    final transitioned = await _transitionToNextSet(decision);
    return transitioned
        ? AssessmentFlowAction.generateSet
        : AssessmentFlowAction.continueSet;
  }

  Future<AssessmentFlowAction> advanceEarlyFailureFlow() async {
    if (!_isAssessment ||
        _isTransitioningSet ||
        _isSubmittingExam ||
        !_currentSetScore.areFirstQuestionsWrong(
          AssessmentFlowPolicy.earlyFailQuestionCount,
        )) {
      return AssessmentFlowAction.continueSet;
    }
    return advanceAssessmentFlow();
  }

  /// Evaluates automatic submit without generating a speculative next set.
  AssessmentFlowAction prepareAssessmentFlow() {
    if (!_isAssessment ||
        _isTransitioningSet ||
        _isSubmittingExam ||
        !canContinue) {
      return AssessmentFlowAction.continueSet;
    }
    return _prepareSubmit();
  }

  bool goToPreviousQuestion() {
    if (_disposed || _questionIndex == 0 || _isTransitioningSet) return false;
    _questionIndex--;
    notifyListeners();
    return true;
  }

  bool goToQuestion(int index) {
    if (_disposed ||
        _isTransitioningSet ||
        index < 0 ||
        index >= (_exam?.questions.length ?? 0) ||
        index == _questionIndex) {
      return false;
    }
    _questionIndex = index;
    notifyListeners();
    return true;
  }

  bool goToNextQuestion() {
    if (_disposed ||
        _isTransitioningSet ||
        (_kind != ExamAttemptKind.other && !canContinue) ||
        _questionIndex >= (_exam?.questions.length ?? 0) - 1) {
      return false;
    }
    _questionIndex++;
    notifyListeners();
    return true;
  }

  Future<ExamAttemptSubmitResult> submitCurrentExam() async {
    if (_disposed || !_requests.isActive || _isSubmittingExam) {
      return const ExamAttemptSubmitResult.ignored();
    }
    final source = _exam;
    if (source == null || source.questions.isEmpty || source.examId == null) {
      _errorMessage = AppStrings.current(AppKeys.missingExamToSubmit);
      _errorRetryAction = null;
      notifyListeners();
      return const ExamAttemptSubmitResult.missingExam();
    }
    final unanswered = firstUnansweredQuestionIndex;
    if (unanswered != null && !_flow.allowsPartialSubmit) {
      _questionIndex = unanswered;
      notifyListeners();
      return const ExamAttemptSubmitResult.unanswered();
    }
    final revision = _operationRevision;
    _errorMessage = null;
    _errorRetryAction = null;
    _isSubmittingExam = true;
    notifyListeners();
    final result = await _requests.submit(
      source,
      _answers.submission(source),
      kind: _kind,
    );
    if (!_canApply(revision)) return const ExamAttemptSubmitResult.ignored();
    _isSubmittingExam = false;
    if (result.exam == null) {
      _errorMessage = result.errorMessage;
      _errorStatus = result.errorStatus;
      _needsNewPaper = result.errorStatus == 13713;
      _errorRetryAction = _needsNewPaper
          ? ExamAttemptRetryAction.generate
          : ExamAttemptRetryAction.submit;
    }
    notifyListeners();
    return result.exam == null
        ? const ExamAttemptSubmitResult.failed()
        : ExamAttemptSubmitResult.submitted(result.exam!);
  }

  Future<bool> _transitionToNextSet(AssessmentFlowDecision decision) async {
    if (_disposed ||
        !_requests.isActive ||
        _isTransitioningSet ||
        _isGeneratingExam ||
        _isSubmittingExam) {
      return false;
    }
    final revision = _operationRevision;
    _flow.beginTransition(decision);
    _errorMessage = null;
    _errorRetryAction = null;
    _isTransitioningSet = true;
    notifyListeners();
    final source = _exam;
    if (source == null || source.examId == null) {
      _isTransitioningSet = false;
      _errorMessage = AppStrings.current(AppKeys.missingExamToSubmit);
      _errorRetryAction = null;
      notifyListeners();
      return false;
    }
    final result = await _requests.transition(
      source: source,
      answers: _answers.submission(source),
      kind: _kind,
      gradeLabel: _isAssessment
          ? AssessmentFlowPolicy.gradeLabel(decision.nextState.grade)
          : gradeLabel,
      level: currentLevel,
    );
    if (!_canApply(revision)) return false;
    _isTransitioningSet = false;
    if (result.exam == null) {
      _errorMessage = result.errorMessage;
      _errorStatus = result.errorStatus;
      _needsNewPaper = result.errorStatus == 13713;
      _errorRetryAction = ExamAttemptRetryAction.generate;
    } else {
      _flow.commitTransition(source, _answers, decision);
      _exam = result.exam;
      _imageRefresher.schedule(_exam);
      _questionIndex = 0;
      _answers.clear();
    }
    notifyListeners();
    return result.exam != null;
  }

  @override
  void dispose() {
    _disposed = true;
    _operationRevision++;
    _imageRefresher.dispose();
    _requests.dispose();
    super.dispose();
  }
}
