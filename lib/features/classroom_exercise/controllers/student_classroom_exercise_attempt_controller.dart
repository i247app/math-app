import 'package:flutter/foundation.dart';

import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';
import 'package:numi/features/classroom_exercise/models/student_classroom_exercise_attempt_question.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

enum StudentClassroomExerciseAttemptError {
  loadFailed,
  submitFailed,
  missingExercise,
}

enum StudentClassroomExerciseRetryAction { load, submit }

enum StudentClassroomExerciseSubmitStatus {
  submitted,
  unanswered,
  missingExercise,
  notOpen,
  failed,
  ignored,
}

class StudentClassroomExerciseSubmitResult {
  const StudentClassroomExerciseSubmitResult(this.status) : submission = null;

  const StudentClassroomExerciseSubmitResult.submitted(
    ClassroomExerciseSubmissionResponse this.submission,
  ) : status = StudentClassroomExerciseSubmitStatus.submitted;

  final StudentClassroomExerciseSubmitStatus status;
  final ClassroomExerciseSubmissionResponse? submission;
}

class StudentClassroomExerciseAttemptController extends ChangeNotifier {
  StudentClassroomExerciseAttemptController({
    required this.exerciseId,
    required this.profileId,
    required ClassroomExerciseService exerciseService,
    ClassroomExercise? initialExercise,
  }) : _exerciseService = exerciseService,
       _exercise = initialExercise {
    if (initialExercise != null) {
      StudentClassroomExerciseCache.seedDetail(
        profileId: profileId,
        exercise: initialExercise,
      );
    }
  }

  final int exerciseId;
  final int profileId;
  final ClassroomExerciseService _exerciseService;

  ClassroomExercise? _exercise;
  int _questionIndex = 0;
  final Map<int, String> _selectedAnswerLabels = <int, String>{};
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _disposed = false;
  int _loadRequestId = 0;
  StudentClassroomExerciseAttemptError? _error;
  String? _errorMessage;
  StudentClassroomExerciseRetryAction? _retryAction;

  ClassroomExercise? get exercise => _exercise;
  List<StudentClassroomExerciseAttemptQuestion> get questions =>
      studentClassroomExerciseAttemptQuestions(_exercise);
  int get questionIndex => _questionIndex;
  Map<int, String> get selectedAnswerLabels =>
      Map<int, String>.unmodifiable(_selectedAnswerLabels);
  String? get selectedAnswerLabel => _selectedAnswerLabels[_questionIndex];
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLastQuestion => _questionIndex >= questions.length - 1;
  StudentClassroomExerciseAttemptError? get error => _error;
  String? get errorMessage => _errorMessage;
  StudentClassroomExerciseRetryAction? get retryAction => _retryAction;

  Future<void> loadDetail({bool forceRefresh = false}) async {
    if (_disposed || _isSubmitting) return;
    final requestId = ++_loadRequestId;
    if (!forceRefresh) {
      final cached = StudentClassroomExerciseCache.peekFullDetail(
        exerciseId: exerciseId,
        profileId: profileId,
      );
      if (cached != null) {
        _exercise = cached;
        forceRefresh = true;
      }
    }

    _isLoading = true;
    _clearError();
    notifyListeners();
    try {
      final exercise = await StudentClassroomExerciseCache.loadDetail(
        service: _exerciseService,
        exerciseId: exerciseId,
        profileId: profileId,
        forceRefresh: forceRefresh,
      );
      if (_disposed || requestId != _loadRequestId) return;
      final shouldResetProgress =
          !forceRefresh || _exercise == null || _selectedAnswerLabels.isEmpty;
      _exercise = exercise ?? _exercise;
      if (shouldResetProgress) {
        _questionIndex = 0;
        _selectedAnswerLabels.clear();
      }
    } on ClassroomExerciseException catch (error) {
      if (_disposed || requestId != _loadRequestId) return;
      _setError(
        StudentClassroomExerciseAttemptError.loadFailed,
        message: error.message,
        retryAction: StudentClassroomExerciseRetryAction.load,
      );
    } catch (_) {
      if (_disposed || requestId != _loadRequestId) return;
      _setError(
        StudentClassroomExerciseAttemptError.loadFailed,
        retryAction: StudentClassroomExerciseRetryAction.load,
      );
    } finally {
      if (!_disposed && requestId == _loadRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectAnswer(StudentClassroomExerciseAttemptAnswer answer) {
    if (_disposed || _isLoading || _isSubmitting) return;
    _selectedAnswerLabels[_questionIndex] = answer.label;
    notifyListeners();
  }

  void goToPreviousQuestion() {
    if (_disposed || _isLoading || _isSubmitting || _questionIndex == 0) return;
    _questionIndex--;
    notifyListeners();
  }

  void goToNextQuestion() {
    if (_disposed || _isLoading || _isSubmitting || isLastQuestion) return;
    _questionIndex++;
    notifyListeners();
  }

  Future<StudentClassroomExerciseSubmitResult> submit() async {
    if (_disposed || _isLoading || _isSubmitting) {
      return const StudentClassroomExerciseSubmitResult(
        StudentClassroomExerciseSubmitStatus.ignored,
      );
    }
    final exercise = _exercise;
    final submissionExerciseId = exercise?.stableId ?? exerciseId;
    if (submissionExerciseId <= 0 || exercise == null) {
      _setError(StudentClassroomExerciseAttemptError.missingExercise);
      notifyListeners();
      return const StudentClassroomExerciseSubmitResult(
        StudentClassroomExerciseSubmitStatus.missingExercise,
      );
    }

    final attemptQuestions = questions;
    if (attemptQuestions.isEmpty ||
        attemptQuestions.any((question) => question.answers.isEmpty)) {
      return const StudentClassroomExerciseSubmitResult(
        StudentClassroomExerciseSubmitStatus.ignored,
      );
    }
    for (var index = 0; index < attemptQuestions.length; index++) {
      if (_selectedAnswerLabels[index] == null) {
        _questionIndex = index;
        notifyListeners();
        return const StudentClassroomExerciseSubmitResult(
          StudentClassroomExerciseSubmitStatus.unanswered,
        );
      }
    }

    final answers = <SubmitClassroomExerciseAnswer>[
      for (var index = 0; index < attemptQuestions.length; index++)
        SubmitClassroomExerciseAnswer(
          questionNumber: attemptQuestions[index].questionNumber,
          label: _selectedAnswerLabels[index]!,
          answer: attemptQuestions[index].selectedAnswerContent(
            _selectedAnswerLabels[index]!,
          ),
          answerContent: attemptQuestions[index].selectedAnswerContent(
            _selectedAnswerLabels[index]!,
          ),
        ),
    ];

    _isSubmitting = true;
    _clearError();
    notifyListeners();
    var keepSubmitting = false;
    try {
      final submission = await _exerciseService.submitExercise(
        profileId: profileId,
        classroomExerciseId: submissionExerciseId,
        answers: answers,
      );
      if (_disposed) {
        return const StudentClassroomExerciseSubmitResult(
          StudentClassroomExerciseSubmitStatus.ignored,
        );
      }
      StudentClassroomExerciseCache.markSubmitted(
        profileId: profileId,
        exercise: exercise,
      );
      return StudentClassroomExerciseSubmitResult.submitted(submission);
    } on ClassroomExerciseException catch (error) {
      if (_disposed) {
        return const StudentClassroomExerciseSubmitResult(
          StudentClassroomExerciseSubmitStatus.ignored,
        );
      }
      if (error.status == 12706) {
        // Keep exit blocked until the screen dismisses the notice and leaves.
        keepSubmitting = true;
        return const StudentClassroomExerciseSubmitResult(
          StudentClassroomExerciseSubmitStatus.notOpen,
        );
      }
      _setError(
        StudentClassroomExerciseAttemptError.submitFailed,
        message: error.message,
        retryAction: StudentClassroomExerciseRetryAction.submit,
      );
      return const StudentClassroomExerciseSubmitResult(
        StudentClassroomExerciseSubmitStatus.failed,
      );
    } catch (_) {
      if (_disposed) {
        return const StudentClassroomExerciseSubmitResult(
          StudentClassroomExerciseSubmitStatus.ignored,
        );
      }
      _setError(
        StudentClassroomExerciseAttemptError.submitFailed,
        retryAction: StudentClassroomExerciseRetryAction.submit,
      );
      return const StudentClassroomExerciseSubmitResult(
        StudentClassroomExerciseSubmitStatus.failed,
      );
    } finally {
      if (!_disposed && !keepSubmitting) {
        _isSubmitting = false;
        notifyListeners();
      }
    }
  }

  void _clearError() {
    _error = null;
    _errorMessage = null;
    _retryAction = null;
  }

  void _setError(
    StudentClassroomExerciseAttemptError error, {
    String? message,
    StudentClassroomExerciseRetryAction? retryAction,
  }) {
    _error = error;
    _errorMessage = message != null && message.trim().isNotEmpty
        ? message
        : null;
    _retryAction = retryAction;
  }

  @override
  void dispose() {
    _disposed = true;
    _loadRequestId++;
    super.dispose();
  }
}
