import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/data/quiz_exception.dart';

enum AssessmentRetryAction { generate, submit }

enum AssessmentSubmitStatus {
  submitted,
  missingQuiz,
  unanswered,
  failed,
  ignored,
}

class AssessmentSubmitResult {
  const AssessmentSubmitResult._(this.status, [this.quiz]);

  const AssessmentSubmitResult.submitted(GeneratedQuiz quiz)
    : this._(AssessmentSubmitStatus.submitted, quiz);

  const AssessmentSubmitResult.missingQuiz()
    : this._(AssessmentSubmitStatus.missingQuiz);

  const AssessmentSubmitResult.unanswered()
    : this._(AssessmentSubmitStatus.unanswered);

  const AssessmentSubmitResult.failed() : this._(AssessmentSubmitStatus.failed);

  const AssessmentSubmitResult.ignored()
    : this._(AssessmentSubmitStatus.ignored);

  final AssessmentSubmitStatus status;
  final GeneratedQuiz? quiz;
}

class AssessmentController extends ChangeNotifier {
  AssessmentController({
    required QuizService quizService,
    GeneratedQuiz? initialQuiz,
    this.purpose = quizPurposeAssessment,
    this.typeOfQuiz = quizTypeGeneral,
    this.gradeLabel,
    this.chapters,
    this.profileId,
  }) : _quizService = quizService,
       _quiz = initialQuiz;

  final QuizService _quizService;
  final String purpose;
  final String typeOfQuiz;
  final String? gradeLabel;
  final List<String>? chapters;
  final int? profileId;

  GeneratedQuiz? _quiz;
  int _questionIndex = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  String? _errorMessage;
  AssessmentRetryAction? _errorRetryAction;
  bool _isGeneratingQuiz = false;
  bool _isSubmittingQuiz = false;
  int _generateRequestId = 0;

  QuizService get quizService => _quizService;
  GeneratedQuiz? get quiz => _quiz;
  int get questionIndex => _questionIndex;
  Map<int, String> get selectedAnswerLabels =>
      Map<int, String>.unmodifiable(_selectedAnswerLabels);
  String? get errorMessage => _errorMessage;
  AssessmentRetryAction? get errorRetryAction => _errorRetryAction;
  bool get isGeneratingQuiz => _isGeneratingQuiz;
  bool get isSubmittingQuiz => _isSubmittingQuiz;

  QuizQuestion? get currentQuestion {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    return questions.isEmpty ? null : questions[_questionIndex];
  }

  String? get selectedAnswerLabel => _selectedAnswerLabels[_questionIndex];

  bool get canContinue => selectedAnswerLabel != null;

  int? get firstUnansweredQuestionIndex {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    return _firstUnansweredIndex(questions);
  }

  bool get allQuestionsAnswered {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    return questions.isNotEmpty && firstUnansweredQuestionIndex == null;
  }

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

  bool? isAnswerCorrect(QuizAnswer answer) {
    final question = currentQuestion;
    if (question == null) {
      return null;
    }

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
    return (_isGeneratingQuiz || currentQuestion == null) &&
        _errorMessage == null;
  }

  bool get isLastQuestion {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    return _questionIndex >= questions.length - 1;
  }

  Future<bool> generateQuiz() async {
    if (_isGeneratingQuiz) {
      return false;
    }

    final requestId = ++_generateRequestId;
    _quiz = null;
    _questionIndex = 0;
    _selectedAnswerLabels.clear();
    _errorMessage = null;
    _errorRetryAction = null;
    _isGeneratingQuiz = true;
    _isSubmittingQuiz = false;
    notifyListeners();

    try {
      final generatedQuiz = await _quizService.generateAssessmentQuiz(
        purpose: purpose,
        typeOfQuiz: typeOfQuiz,
        gradeLabel: gradeLabel,
        chapters: chapters,
        profileId: profileId,
      );
      if (requestId != _generateRequestId) {
        return false;
      }

      QuizCache.seedDetail(generatedQuiz);
      _quiz = generatedQuiz;
      _isGeneratingQuiz = false;
      notifyListeners();
      return true;
    } on QuizException catch (error) {
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

  void selectAnswer(QuizAnswer answer) {
    if (_selectedAnswerLabels[_questionIndex] == answer.label) {
      _selectedAnswerLabels.remove(_questionIndex);
    } else {
      _selectedAnswerLabels[_questionIndex] = answer.label;
    }
    notifyListeners();
  }

  bool goToPreviousQuestion() {
    if (_questionIndex == 0) {
      return false;
    }
    _questionIndex--;
    notifyListeners();
    return true;
  }

  bool goToQuestion(int index) {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    if (index < 0 || index >= questions.length || index == _questionIndex) {
      return false;
    }

    _questionIndex = index;
    notifyListeners();
    return true;
  }

  bool goToNextQuestion() {
    final questions = _quiz?.questions ?? const <QuizQuestion>[];
    if (_questionIndex >= questions.length - 1) {
      return false;
    }

    _questionIndex++;
    notifyListeners();
    return true;
  }

  Future<AssessmentSubmitResult> submitCurrentQuiz() async {
    if (_isSubmittingQuiz) {
      return const AssessmentSubmitResult.ignored();
    }

    final currentQuiz = _quiz;
    final questions = currentQuiz?.questions ?? const <QuizQuestion>[];
    final quizId = currentQuiz?.quizId;
    if (currentQuiz == null || questions.isEmpty || quizId == null) {
      _errorMessage = AppStrings.current(AppKeys.missingQuizToSubmit);
      _errorRetryAction = null;
      notifyListeners();
      return const AssessmentSubmitResult.missingQuiz();
    }

    final firstUnansweredIndex = _firstUnansweredIndex(questions);
    if (firstUnansweredIndex != null) {
      _questionIndex = firstUnansweredIndex;
      notifyListeners();
      return const AssessmentSubmitResult.unanswered();
    }

    final answers = <SubmitQuizAnswer>[
      for (var index = 0; index < questions.length; index++)
        SubmitQuizAnswer(
          questionNumber: questions[index].questionNumber,
          label: _selectedAnswerLabels[index]!,
        ),
    ];

    _errorMessage = null;
    _errorRetryAction = null;
    _isSubmittingQuiz = true;
    notifyListeners();

    try {
      final submittedQuiz = await _quizService.submitQuiz(
        quizId: quizId,
        answers: answers,
        profileId: profileId,
      );
      final submittedProfileId =
          profileId ?? submittedQuiz.profileId ?? currentQuiz.profileId;
      QuizCache.seedDetail(submittedQuiz);
      QuizCache.invalidateLists(profileId: submittedProfileId);
      return AssessmentSubmitResult.submitted(submittedQuiz);
    } on QuizException catch (error) {
      _errorMessage = error.message;
      _errorRetryAction = AssessmentRetryAction.submit;
      return const AssessmentSubmitResult.failed();
    } catch (_) {
      _errorMessage = AppStrings.current(AppKeys.submitQuizFailed);
      _errorRetryAction = AssessmentRetryAction.submit;
      return const AssessmentSubmitResult.failed();
    } finally {
      _isSubmittingQuiz = false;
      notifyListeners();
    }
  }

  void _handleGenerationFailure(String message) {
    _isGeneratingQuiz = false;
    _errorMessage = message;
    _errorRetryAction = AssessmentRetryAction.generate;
    notifyListeners();
  }

  int? _firstUnansweredIndex(List<QuizQuestion> questions) {
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
