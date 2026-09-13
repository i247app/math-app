import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

const assessmentCorrectAnswerTarget =
    AssessmentFlowPolicy.firstQuestionsUpgradeTarget;

enum AssessmentRetryAction { generate, submit }

enum AssessmentSubmitStatus {
  submitted,
  missingExam,
  unanswered,
  failed,
  ignored,
}

class AssessmentSubmitResult {
  const AssessmentSubmitResult._(this.status, [this.exam]);

  const AssessmentSubmitResult.submitted(GeneratedExam exam)
    : this._(AssessmentSubmitStatus.submitted, exam);

  const AssessmentSubmitResult.missingExam()
    : this._(AssessmentSubmitStatus.missingExam);

  const AssessmentSubmitResult.unanswered()
    : this._(AssessmentSubmitStatus.unanswered);

  const AssessmentSubmitResult.failed() : this._(AssessmentSubmitStatus.failed);

  const AssessmentSubmitResult.ignored()
    : this._(AssessmentSubmitStatus.ignored);

  final AssessmentSubmitStatus status;
  final GeneratedExam? exam;
}

class AssessmentSetRecord {
  AssessmentSetRecord({
    required this.exam,
    required this.grade,
    required this.mode,
    required this.setNumber,
    required Map<int, String> selectedAnswerLabels,
    required this.correctAnswerCount,
  }) : selectedAnswerLabels = Map<int, String>.unmodifiable(
         selectedAnswerLabels,
       );

  final GeneratedExam exam;
  final int grade;
  final AssessmentFlowMode mode;
  final int setNumber;
  final Map<int, String> selectedAnswerLabels;
  final int correctAnswerCount;
}

class AssessmentController extends ChangeNotifier {
  AssessmentController({
    required ExamService examService,
    GeneratedExam? initialExam,
    this.examType = examTypeAssessment,
    this.gradeLabel,
    this.profileId,
    this.startAtKindergarten = true,
  }) : _examService = examService,
       _exam = initialExam {
    final fallbackGrade = _isAssessment ? 0 : 1;
    _flowState = AssessmentFlowState(
      grade: AssessmentFlowPolicy.clampGrade(
        initialExam?.grade ??
            AssessmentFlowPolicy.gradeFromLabel(
              gradeLabel,
              fallback: fallbackGrade,
            ),
      ),
    );
  }

  final ExamService _examService;
  final String examType;
  final String? gradeLabel;
  final int? profileId;
  final bool startAtKindergarten;

  GeneratedExam? _exam;
  late AssessmentFlowState _flowState;
  int _questionIndex = 0;
  int _questionNumberOffset = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  final List<AssessmentSetRecord> _completedSets = <AssessmentSetRecord>[];
  final Map<int, GeneratedExam> _submittedSets = <int, GeneratedExam>{};
  String? _errorMessage;
  AssessmentRetryAction? _errorRetryAction;
  bool _isGeneratingExam = false;
  bool _isTransitioningSet = false;
  bool _isSubmittingExam = false;
  bool _allowsPartialSubmit = false;
  int _generateRequestId = 0;
  AssessmentFlowDecision? _pendingGenerationDecision;
  GeneratedExam? _pendingGeneratedExam;

  bool get _isAssessment {
    return (_exam?.examType ?? examType).trim().toUpperCase() ==
        examTypeAssessment;
  }

  ExamService get examService => _examService;
  GeneratedExam? get exam => _exam;
  bool get isAssessment => _isAssessment;
  int get questionIndex => _questionIndex;
  int get questionNumberOffset => _questionNumberOffset;
  int get progressQuestionIndex => _isTransitioningSet ? 1 : _questionIndex + 1;
  int get progressQuestionNumberOffset => _isTransitioningSet
      ? _questionNumberOffset + _selectedAnswerLabels.length
      : _questionNumberOffset;
  int get displayedQuestionNumber =>
      progressQuestionNumberOffset + progressQuestionIndex;
  int get currentGrade => _flowState.grade;
  String get currentGradeLabel => AssessmentFlowPolicy.gradeLabel(currentGrade);
  int get setNumber => _flowState.setNumber;
  AssessmentFlowMode get flowMode => _flowState.mode;
  bool get isFailed => _flowState.isFailed;
  List<AssessmentSetRecord> get completedSets =>
      List<AssessmentSetRecord>.unmodifiable(_completedSets);
  Map<int, String> get selectedAnswerLabels =>
      Map<int, String>.unmodifiable(_selectedAnswerLabels);
  String? get errorMessage => _errorMessage;
  AssessmentRetryAction? get errorRetryAction => _errorRetryAction;
  bool get isGeneratingExam => _isGeneratingExam || _isTransitioningSet;
  bool get isTransitioningSet => _isTransitioningSet;
  bool get isSubmittingExam => _isSubmittingExam;

  ExamQuestion? get currentQuestion {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (questions.isEmpty || _questionIndex >= questions.length) {
      return null;
    }
    return questions[_questionIndex];
  }

  String? get selectedAnswerLabel => _selectedAnswerLabels[_questionIndex];

  bool get canContinue => selectedAnswerLabel != null;

  int? get firstUnansweredQuestionIndex {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    return _firstUnansweredIndex(questions);
  }

  bool get allQuestionsAnswered {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    return questions.isNotEmpty && firstUnansweredQuestionIndex == null;
  }

  int get correctAnswerCount => _currentSetScore.correctCount;
  int get totalCorrectAnswerCount =>
      _completedSets.fold<int>(
        0,
        (total, set) => total + set.correctAnswerCount,
      ) +
      correctAnswerCount;
  int get totalAnsweredQuestionCount =>
      _completedSets.fold<int>(
        0,
        (total, set) => total + set.selectedAnswerLabels.length,
      ) +
      _selectedAnswerLabels.length;

  bool get shouldAutoSubmitAssessment => _allowsPartialSubmit;

  bool? get isSelectedAnswerCorrect {
    final question = currentQuestion;
    final selectedLabel = selectedAnswerLabel;
    if (question == null || selectedLabel == null) {
      return null;
    }

    for (final answer in question.answers) {
      if (_normalizedAnswerValue(answer.label) ==
          _normalizedAnswerValue(selectedLabel)) {
        return isAnswerCorrect(answer);
      }
    }
    return null;
  }

  bool? isAnswerCorrect(ExamAnswer answer) {
    final question = currentQuestion;
    if (question == null) {
      return null;
    }

    return _isAnswerCorrect(question, answer);
  }

  bool? _isAnswerCorrect(ExamQuestion question, ExamAnswer answer) {
    final correctValues = <String?>[
      question.rightAnswer,
      question.correctAnswer,
    ].map(_normalizedAnswerValue).whereType<String>().toSet();
    if (correctValues.isEmpty) {
      return null;
    }

    return correctValues.contains(_normalizedAnswerValue(answer.label)) ||
        correctValues.contains(_normalizedAnswerValue(answer.content));
  }

  bool get isGeneratingQuestion {
    return (_isGeneratingExam || currentQuestion == null) &&
        _errorMessage == null;
  }

  bool get isLastQuestion {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    return _questionIndex >= questions.length - 1;
  }

  Future<bool> generateExam() async {
    if (_isGeneratingExam || _isTransitioningSet) {
      return false;
    }

    final requestId = ++_generateRequestId;
    final initialGrade = _isAssessment && startAtKindergarten
        ? AssessmentFlowPolicy.minimumGrade
        : AssessmentFlowPolicy.gradeFromLabel(
            gradeLabel,
            fallback: _isAssessment ? 0 : 1,
          );
    _flowState = AssessmentFlowState(grade: initialGrade);
    _exam = null;
    _questionIndex = 0;
    _questionNumberOffset = 0;
    _selectedAnswerLabels.clear();
    _completedSets.clear();
    _submittedSets.clear();
    _pendingGenerationDecision = null;
    _pendingGeneratedExam = null;
    _allowsPartialSubmit = false;
    _errorMessage = null;
    _errorRetryAction = null;
    _isGeneratingExam = true;
    _isSubmittingExam = false;
    notifyListeners();

    try {
      final generatedExam = await _generateInitialSet(initialGrade);
      if (requestId != _generateRequestId) {
        return false;
      }

      _exam = generatedExam;
      _isGeneratingExam = false;
      notifyListeners();
      return true;
    } on ExamException catch (error) {
      if (requestId != _generateRequestId) {
        return false;
      }
      _handleGenerationFailure(error.message);
    } catch (_) {
      if (requestId != _generateRequestId) {
        return false;
      }
      _handleGenerationFailure(
        AppStrings.current(AppKeys.createQuestionFailed),
      );
    }

    return false;
  }

  Future<bool> retryGeneration() async {
    final decision = _pendingGenerationDecision;
    if (decision == null) {
      return generateExam();
    }
    return _transitionToNextSet(decision);
  }

  void selectAnswer(ExamAnswer answer) {
    if (_isTransitioningSet || _isSubmittingExam) {
      return;
    }
    _allowsPartialSubmit = false;
    if (_selectedAnswerLabels[_questionIndex] == answer.label) {
      _selectedAnswerLabels.remove(_questionIndex);
    } else {
      _selectedAnswerLabels[_questionIndex] = answer.label;
    }
    notifyListeners();
  }

  Future<AssessmentFlowAction> advanceAssessmentFlow() async {
    if (!_isAssessment || _isTransitioningSet || _isSubmittingExam) {
      return AssessmentFlowAction.continueSet;
    }

    final score = _currentSetScore;
    final decision = AssessmentFlowPolicy.decide(_flowState, score);
    if (decision.action == AssessmentFlowAction.continueSet) {
      return decision.action;
    }
    if (decision.action == AssessmentFlowAction.submit) {
      _flowState = decision.nextState;
      _allowsPartialSubmit = !score.isComplete;
      notifyListeners();
      return decision.action;
    }

    final transitioned = await _transitionToNextSet(decision);
    return transitioned
        ? AssessmentFlowAction.generateSet
        : AssessmentFlowAction.continueSet;
  }

  Future<AssessmentFlowAction> advanceConsecutiveFailureFlow() async {
    if (!_isAssessment ||
        _isTransitioningSet ||
        _isSubmittingExam ||
        !_currentSetScore.hasConsecutiveIncorrectAnswersInFirstQuestions(
          questionCount: AssessmentFlowPolicy.earlyDowngradeQuestionCount,
          incorrectCount: AssessmentFlowPolicy.consecutiveIncorrectTarget,
        )) {
      return AssessmentFlowAction.continueSet;
    }
    return advanceAssessmentFlow();
  }

  /// Evaluates automatic submit without generating a speculative next set.
  AssessmentFlowAction prepareAssessmentFlow() {
    if (!_isAssessment || _isTransitioningSet || _isSubmittingExam) {
      return AssessmentFlowAction.continueSet;
    }

    final score = _currentSetScore;
    final decision = AssessmentFlowPolicy.decide(_flowState, score);
    if (decision.action != AssessmentFlowAction.submit) {
      return AssessmentFlowAction.continueSet;
    }

    _flowState = decision.nextState;
    _allowsPartialSubmit = !score.isComplete;
    notifyListeners();
    return AssessmentFlowAction.submit;
  }

  bool goToPreviousQuestion() {
    if (_questionIndex == 0 || _isTransitioningSet) {
      return false;
    }
    _questionIndex--;
    notifyListeners();
    return true;
  }

  bool goToQuestion(int index) {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (_isTransitioningSet ||
        index < 0 ||
        index >= questions.length ||
        index == _questionIndex) {
      return false;
    }

    _questionIndex = index;
    notifyListeners();
    return true;
  }

  bool goToNextQuestion() {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (_isTransitioningSet || _questionIndex >= questions.length - 1) {
      return false;
    }

    _questionIndex++;
    notifyListeners();
    return true;
  }

  Future<AssessmentSubmitResult> submitCurrentExam() async {
    if (_isSubmittingExam) {
      return const AssessmentSubmitResult.ignored();
    }

    final currentExam = _exam;
    final questions = currentExam?.questions ?? const <ExamQuestion>[];
    final examId = currentExam?.examId;
    if (currentExam == null || questions.isEmpty || examId == null) {
      _errorMessage = AppStrings.current(AppKeys.missingExamToSubmit);
      _errorRetryAction = null;
      notifyListeners();
      return const AssessmentSubmitResult.missingExam();
    }

    final firstUnansweredIndex = _firstUnansweredIndex(questions);
    if (firstUnansweredIndex != null && !_allowsPartialSubmit) {
      _questionIndex = firstUnansweredIndex;
      notifyListeners();
      return const AssessmentSubmitResult.unanswered();
    }

    final answers = _answersForExam(currentExam);

    _errorMessage = null;
    _errorRetryAction = null;
    _isSubmittingExam = true;
    notifyListeners();

    try {
      final submittedExam = await _submitSet(currentExam, answers);
      if (_isAssessment) {
        final userExamId = submittedExam.userExamId;
        if (userExamId == null || userExamId <= 0) {
          throw ExamException(AppStrings.current(AppKeys.missingExamIdShort));
        }
        await _examService.updateUserExamStatus(
          userExamId: userExamId,
          status: 'COMPLETE',
          profileId: profileId ?? currentExam.profileId,
        );
      }
      return AssessmentSubmitResult.submitted(submittedExam);
    } on ExamException catch (error) {
      _errorMessage = error.message;
      _errorRetryAction = AssessmentRetryAction.submit;
      return const AssessmentSubmitResult.failed();
    } catch (_) {
      _errorMessage = AppStrings.current(AppKeys.submitExamFailed);
      _errorRetryAction = AssessmentRetryAction.submit;
      return const AssessmentSubmitResult.failed();
    } finally {
      _isSubmittingExam = false;
      notifyListeners();
    }
  }

  AssessmentSetScore get _currentSetScore {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    final correctIndexes = <int>{};
    for (final entry in _selectedAnswerLabels.entries) {
      if (entry.key < 0 || entry.key >= questions.length) {
        continue;
      }
      final question = questions[entry.key];
      final selectedLabel = _normalizedAnswerValue(entry.value);
      for (final answer in question.answers) {
        if (_normalizedAnswerValue(answer.label) == selectedLabel &&
            _isAnswerCorrect(question, answer) == true) {
          correctIndexes.add(entry.key);
          break;
        }
      }
    }
    return AssessmentSetScore(
      totalQuestions: questions.length,
      answeredQuestionIndexes: _selectedAnswerLabels.keys.toSet(),
      correctQuestionIndexes: correctIndexes,
    );
  }

  Future<bool> _transitionToNextSet(AssessmentFlowDecision decision) async {
    _pendingGenerationDecision = decision;
    if (decision.nextState.isFailed && !_flowState.isFailed) {
      _flowState = _flowState.copyWith(isFailed: true);
    }
    _errorMessage = null;
    _errorRetryAction = null;
    _isTransitioningSet = true;
    notifyListeners();

    final currentExam = _exam;
    final currentExamId = currentExam?.examId;
    if (currentExam == null || currentExamId == null) {
      _isTransitioningSet = false;
      _errorMessage = AppStrings.current(AppKeys.missingExamToSubmit);
      _errorRetryAction = null;
      notifyListeners();
      return false;
    }

    final targetGrade = decision.nextState.grade;
    final generatedSetRequest = _pendingGeneratedExam == null
        ? _requestSet(targetGrade)
        : Future<_GeneratedSetResult>.value(
            _GeneratedSetResult.success(_pendingGeneratedExam!),
          );
    final results = await Future.wait<Object>(<Future<Object>>[
      _requestSubmittedSet(currentExam, _answersForExam(currentExam)),
      generatedSetRequest,
    ]);
    final submittedSetResult = results[0] as _SubmittedSetResult;
    final generatedSetResult = results[1] as _GeneratedSetResult;
    if (generatedSetResult.exam != null) {
      _pendingGeneratedExam = generatedSetResult.exam;
    }

    if (submittedSetResult.exam == null || generatedSetResult.exam == null) {
      _isTransitioningSet = false;
      _errorMessage =
          submittedSetResult.errorMessage ??
          generatedSetResult.errorMessage ??
          AppStrings.current(AppKeys.createQuestionFailed);
      _errorRetryAction = AssessmentRetryAction.generate;
      notifyListeners();
      return false;
    }

    _completedSets.add(
      AssessmentSetRecord(
        exam: currentExam,
        grade: _flowState.grade,
        mode: _flowState.mode,
        setNumber: _flowState.setNumber,
        selectedAnswerLabels: _selectedAnswerLabels,
        correctAnswerCount: correctAnswerCount,
      ),
    );

    _questionNumberOffset += _selectedAnswerLabels.length;
    _exam = generatedSetResult.exam;
    _flowState = decision.nextState;
    _questionIndex = 0;
    _selectedAnswerLabels.clear();
    _allowsPartialSubmit = false;
    _pendingGenerationDecision = null;
    _pendingGeneratedExam = null;
    _isTransitioningSet = false;
    notifyListeners();
    return true;
  }

  Future<GeneratedExam> _generateSet(int grade) async {
    final generatedExam = await _examService.generateAssessmentExam(
      examType: examType,
      gradeLabel: _isAssessment
          ? AssessmentFlowPolicy.gradeLabel(grade)
          : gradeLabel,
      profileId: profileId,
    );
    ExamCache.seedDetail(generatedExam);
    return generatedExam;
  }

  Future<GeneratedExam> _generateInitialSet(int grade) async {
    final generatedExam = await _examService.generateAssessmentExam(
      examType: examType,
      gradeLabel: _isAssessment && startAtKindergarten
          ? AssessmentFlowPolicy.gradeLabel(grade)
          : gradeLabel,
      profileId: profileId,
    );
    ExamCache.seedDetail(generatedExam);
    return generatedExam;
  }

  Future<_GeneratedSetResult> _requestSet(int grade) async {
    try {
      return _GeneratedSetResult.success(await _generateSet(grade));
    } on ExamException catch (error) {
      return _GeneratedSetResult.failure(error.message);
    } catch (_) {
      return _GeneratedSetResult.failure(
        AppStrings.current(AppKeys.createQuestionFailed),
      );
    }
  }

  List<SubmitExamAnswer> _answersForExam(GeneratedExam exam) {
    return <SubmitExamAnswer>[
      for (var index = 0; index < exam.questions.length; index++)
        if (_selectedAnswerLabels[index] case final label?)
          SubmitExamAnswer(
            questionNumber: exam.questions[index].questionNumber,
            label: label,
          ),
    ];
  }

  Future<GeneratedExam> _submitSet(
    GeneratedExam exam,
    List<SubmitExamAnswer> answers,
  ) async {
    final examId = exam.examId;
    if (examId == null) {
      throw ExamException(AppStrings.current(AppKeys.missingExamToSubmit));
    }
    final cached = _submittedSets[examId];
    if (cached != null) {
      return cached;
    }

    final submittedExam = await _examService.submitExam(
      examId: examId,
      answers: answers,
      profileId: profileId ?? exam.profileId,
    );
    _submittedSets[examId] = submittedExam;
    final submittedProfileId =
        profileId ?? submittedExam.profileId ?? exam.profileId;
    ExamCache.seedDetail(submittedExam);
    ExamCache.invalidateLists(profileId: submittedProfileId);
    return submittedExam;
  }

  Future<_SubmittedSetResult> _requestSubmittedSet(
    GeneratedExam exam,
    List<SubmitExamAnswer> answers,
  ) async {
    try {
      return _SubmittedSetResult.success(await _submitSet(exam, answers));
    } on ExamException catch (error) {
      return _SubmittedSetResult.failure(error.message);
    } catch (_) {
      return _SubmittedSetResult.failure(
        AppStrings.current(AppKeys.submitExamFailed),
      );
    }
  }

  void _handleGenerationFailure(String message) {
    _isGeneratingExam = false;
    _isTransitioningSet = false;
    _errorMessage = message;
    _errorRetryAction = AssessmentRetryAction.generate;
    notifyListeners();
  }

  int? _firstUnansweredIndex(List<ExamQuestion> questions) {
    for (var index = 0; index < questions.length; index++) {
      if (_selectedAnswerLabels[index] == null) {
        return index;
      }
    }
    return null;
  }

  String? _normalizedAnswerValue(String? value) {
    final normalized = value?.trim().toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

class _GeneratedSetResult {
  const _GeneratedSetResult.success(this.exam) : errorMessage = null;

  const _GeneratedSetResult.failure(this.errorMessage) : exam = null;

  final GeneratedExam? exam;
  final String? errorMessage;
}

class _SubmittedSetResult {
  const _SubmittedSetResult.success(this.exam) : errorMessage = null;

  const _SubmittedSetResult.failure(this.errorMessage) : exam = null;

  final GeneratedExam? exam;
  final String? errorMessage;
}
