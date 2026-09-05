import 'package:flutter/foundation.dart';

import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/application/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/application/read_models/student_homework_attempt_question.dart';
import 'package:numi/features/homework/data/cache/student_homework_cache.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';

enum StudentHomeworkAttemptError { loadFailed, submitFailed, missingExercise }

enum StudentHomeworkRetryAction { load, submit }

enum StudentHomeworkSubmitStatus {
  submitted,
  unanswered,
  missingExercise,
  notOpen,
  failed,
  ignored,
}

class StudentHomeworkSubmitResult {
  const StudentHomeworkSubmitResult(this.status) : submission = null;

  const StudentHomeworkSubmitResult.submitted(
    ClassroomExerciseSubmissionResponse this.submission,
  ) : status = StudentHomeworkSubmitStatus.submitted;

  final StudentHomeworkSubmitStatus status;
  final ClassroomExerciseSubmissionResponse? submission;
}

class StudentHomeworkAttemptController extends ChangeNotifier {
  StudentHomeworkAttemptController({
    required this.exerciseId,
    required this.profileId,
    required ClassroomExerciseService exerciseService,
    ClassroomExercise? initialExercise,
  }) : _exerciseService = exerciseService,
       _exercise = initialExercise {
    if (initialExercise != null) {
      StudentHomeworkCache.seedDetail(
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
  StudentHomeworkAttemptError? _error;
  String? _errorMessage;
  StudentHomeworkRetryAction? _retryAction;

  ClassroomExercise? get exercise => _exercise;
  List<StudentHomeworkAttemptQuestion> get questions =>
      studentHomeworkAttemptQuestions(_exercise);
  int get questionIndex => _questionIndex;
  Map<int, String> get selectedAnswerLabels =>
      Map<int, String>.unmodifiable(_selectedAnswerLabels);
  String? get selectedAnswerLabel => _selectedAnswerLabels[_questionIndex];
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLastQuestion => _questionIndex >= questions.length - 1;
  StudentHomeworkAttemptError? get error => _error;
  String? get errorMessage => _errorMessage;
  StudentHomeworkRetryAction? get retryAction => _retryAction;

  Future<void> loadDetail({bool forceRefresh = false}) async {
    if (_disposed || _isSubmitting) return;
    final requestId = ++_loadRequestId;
    if (!forceRefresh) {
      final cached = StudentHomeworkCache.peekFullDetail(
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
      final exercise = await StudentHomeworkCache.loadDetail(
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
        StudentHomeworkAttemptError.loadFailed,
        message: error.message,
        retryAction: StudentHomeworkRetryAction.load,
      );
    } catch (_) {
      if (_disposed || requestId != _loadRequestId) return;
      _setError(
        StudentHomeworkAttemptError.loadFailed,
        retryAction: StudentHomeworkRetryAction.load,
      );
    } finally {
      if (!_disposed && requestId == _loadRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void selectAnswer(StudentHomeworkAttemptAnswer answer) {
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

  Future<StudentHomeworkSubmitResult> submit() async {
    if (_disposed || _isLoading || _isSubmitting) {
      return const StudentHomeworkSubmitResult(
        StudentHomeworkSubmitStatus.ignored,
      );
    }
    final exercise = _exercise;
    final submissionExerciseId = exercise?.stableId ?? exerciseId;
    if (submissionExerciseId <= 0 || exercise == null) {
      _setError(StudentHomeworkAttemptError.missingExercise);
      notifyListeners();
      return const StudentHomeworkSubmitResult(
        StudentHomeworkSubmitStatus.missingExercise,
      );
    }

    final attemptQuestions = questions;
    if (attemptQuestions.isEmpty ||
        attemptQuestions.any((question) => question.answers.isEmpty)) {
      return const StudentHomeworkSubmitResult(
        StudentHomeworkSubmitStatus.ignored,
      );
    }
    for (var index = 0; index < attemptQuestions.length; index++) {
      if (_selectedAnswerLabels[index] == null) {
        _questionIndex = index;
        notifyListeners();
        return const StudentHomeworkSubmitResult(
          StudentHomeworkSubmitStatus.unanswered,
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
        return const StudentHomeworkSubmitResult(
          StudentHomeworkSubmitStatus.ignored,
        );
      }
      StudentHomeworkCache.markSubmitted(
        profileId: profileId,
        exercise: exercise,
      );
      return StudentHomeworkSubmitResult.submitted(submission);
    } on ClassroomExerciseException catch (error) {
      if (_disposed) {
        return const StudentHomeworkSubmitResult(
          StudentHomeworkSubmitStatus.ignored,
        );
      }
      if (error.status == 12706) {
        // Keep exit blocked until the screen dismisses the notice and leaves.
        keepSubmitting = true;
        return const StudentHomeworkSubmitResult(
          StudentHomeworkSubmitStatus.notOpen,
        );
      }
      _setError(
        StudentHomeworkAttemptError.submitFailed,
        message: error.message,
        retryAction: StudentHomeworkRetryAction.submit,
      );
      return const StudentHomeworkSubmitResult(
        StudentHomeworkSubmitStatus.failed,
      );
    } catch (_) {
      if (_disposed) {
        return const StudentHomeworkSubmitResult(
          StudentHomeworkSubmitStatus.ignored,
        );
      }
      _setError(
        StudentHomeworkAttemptError.submitFailed,
        retryAction: StudentHomeworkRetryAction.submit,
      );
      return const StudentHomeworkSubmitResult(
        StudentHomeworkSubmitStatus.failed,
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
    StudentHomeworkAttemptError error, {
    String? message,
    StudentHomeworkRetryAction? retryAction,
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
