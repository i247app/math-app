import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_exception.dart';

const assessmentCorrectAnswerTarget = 6;

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

class AssessmentController extends ChangeNotifier {
  AssessmentController({
    required ExamService examService,
    GeneratedExam? initialExam,
    this.examType = examTypeAssessment,
    this.gradeLabel,
    this.profileId,
  }) : _examService = examService,
       _exam = initialExam;

  final ExamService _examService;
  final String examType;
  final String? gradeLabel;
  final int? profileId;

  GeneratedExam? _exam;
  int _questionIndex = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  String? _errorMessage;
  AssessmentRetryAction? _errorRetryAction;
  bool _isGeneratingExam = false;
  bool _isSubmittingExam = false;
  int _generateRequestId = 0;

  ExamService get examService => _examService;
  GeneratedExam? get exam => _exam;
  int get questionIndex => _questionIndex;
  Map<int, String> get selectedAnswerLabels =>
      Map<int, String>.unmodifiable(_selectedAnswerLabels);
  String? get errorMessage => _errorMessage;
  AssessmentRetryAction? get errorRetryAction => _errorRetryAction;
  bool get isGeneratingExam => _isGeneratingExam;
  bool get isSubmittingExam => _isSubmittingExam;

  ExamQuestion? get currentQuestion {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    return questions.isEmpty ? null : questions[_questionIndex];
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

  int get correctAnswerCount {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    var count = 0;
    for (final entry in _selectedAnswerLabels.entries) {
      if (entry.key < 0 || entry.key >= questions.length) {
        continue;
      }
      final question = questions[entry.key];
      final selectedLabel = _normalizedAnswerValue(entry.value);
      for (final answer in question.answers) {
        if (_normalizedAnswerValue(answer.label) == selectedLabel &&
            _isAnswerCorrect(question, answer) == true) {
          count++;
          break;
        }
      }
    }
    return count;
  }

  bool get shouldAutoSubmitAssessment {
    final effectiveExamType = (_exam?.examType ?? examType)
        .trim()
        .toUpperCase();
    return effectiveExamType == examTypeAssessment &&
        correctAnswerCount >= assessmentCorrectAnswerTarget;
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
    if (_isGeneratingExam) {
      return false;
    }

    final requestId = ++_generateRequestId;
    _exam = null;
    _questionIndex = 0;
    _selectedAnswerLabels.clear();
    _errorMessage = null;
    _errorRetryAction = null;
    _isGeneratingExam = true;
    _isSubmittingExam = false;
    notifyListeners();

    try {
      final generatedExam = await _examService.generateAssessmentExam(
        examType: examType,
        gradeLabel: gradeLabel,
        profileId: profileId,
      );
      if (requestId != _generateRequestId) {
        return false;
      }

      ExamCache.seedDetail(generatedExam);
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

  void selectAnswer(ExamAnswer answer) {
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
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (index < 0 || index >= questions.length || index == _questionIndex) {
      return false;
    }

    _questionIndex = index;
    notifyListeners();
    return true;
  }

  bool goToNextQuestion() {
    final questions = _exam?.questions ?? const <ExamQuestion>[];
    if (_questionIndex >= questions.length - 1) {
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
    if (firstUnansweredIndex != null && !shouldAutoSubmitAssessment) {
      _questionIndex = firstUnansweredIndex;
      notifyListeners();
      return const AssessmentSubmitResult.unanswered();
    }

    final answers = <SubmitExamAnswer>[
      for (var index = 0; index < questions.length; index++)
        if (_selectedAnswerLabels[index] case final label?)
          SubmitExamAnswer(
            questionNumber: questions[index].questionNumber,
            label: label,
          ),
    ];

    _errorMessage = null;
    _errorRetryAction = null;
    _isSubmittingExam = true;
    notifyListeners();

    try {
      final submittedExam = await _examService.submitExam(
        examId: examId,
        answers: answers,
        profileId: profileId,
      );
      final submittedProfileId =
          profileId ?? submittedExam.profileId ?? currentExam.profileId;
      ExamCache.seedDetail(submittedExam);
      ExamCache.invalidateLists(profileId: submittedProfileId);
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

  void _handleGenerationFailure(String message) {
    _isGeneratingExam = false;
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
