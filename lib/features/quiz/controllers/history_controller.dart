import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/quiz/models/quiz.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/quiz/data/quiz_cache.dart';
import 'package:numi/features/quiz/data/quiz_history_classroom_exercise_cache.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/data/quiz_exception.dart';
import 'package:numi/features/quiz/helpers/history_compare_classroom_exercise_descending.dart';
import 'package:numi/features/quiz/helpers/history_compare_quiz_descending.dart';
import 'package:numi/features/quiz/helpers/history_is_assessment_quiz.dart';
import 'package:numi/features/quiz/helpers/history_is_submitted_classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';

class HistoryController extends ChangeNotifier {
  HistoryController({
    required QuizService quizService,
    required ClassroomService classroomService,
    required ClassroomExerciseService assignmentService,
  }) : _quizService = quizService,
       _classroomService = classroomService,
       _assignmentService = assignmentService;

  final QuizService _quizService;
  final ClassroomService _classroomService;
  final ClassroomExerciseService _assignmentService;

  List<GeneratedQuiz> _assessmentQuizzes = const <GeneratedQuiz>[];
  List<ClassroomExercise> _classroomExerciseExercises =
      const <ClassroomExercise>[];
  bool _isLoadingAssessments = true;
  bool _isLoadingClassroomExercise = true;
  String? _assessmentErrorMessage;
  String? _classroomExerciseErrorMessage;
  int _loadRequestId = 0;
  bool _disposed = false;

  List<GeneratedQuiz> get assessmentQuizzes => _assessmentQuizzes;
  List<ClassroomExercise> get classroomExerciseExercises =>
      _classroomExerciseExercises;
  bool get isLoadingAssessments => _isLoadingAssessments;
  bool get isLoadingClassroomExercise => _isLoadingClassroomExercise;
  String? get assessmentErrorMessage => _assessmentErrorMessage;
  String? get classroomExerciseErrorMessage => _classroomExerciseErrorMessage;

  Future<void> loadHistory({
    required int? profileId,
    bool forceRefresh = false,
  }) async {
    final requestId = ++_loadRequestId;
    if (profileId == null) {
      final message = AppStrings.current(AppKeys.noAccountForHistory);
      _isLoadingAssessments = false;
      _isLoadingClassroomExercise = false;
      _assessmentErrorMessage = message;
      _classroomExerciseErrorMessage = message;
      _assessmentQuizzes = const <GeneratedQuiz>[];
      _classroomExerciseExercises = const <ClassroomExercise>[];
      _notifyIfAlive();
      return;
    }

    final cachedQuizzes = QuizCache.peekList(profileId: profileId);
    final cachedClassroomExercise =
        QuizHistoryClassroomExerciseCache.peekSubmittedClassroomExercise(
          profileId,
        );
    final shouldRefreshAssessments =
        forceRefresh || !QuizCache.isListFresh(profileId: profileId);
    final shouldRefreshClassroomExercise =
        forceRefresh || !QuizHistoryClassroomExerciseCache.isFresh(profileId);

    if (cachedQuizzes != null) {
      _assessmentQuizzes = _assessmentHistoryQuizzes(cachedQuizzes);
      _assessmentErrorMessage = null;
    } else {
      _assessmentQuizzes = const <GeneratedQuiz>[];
      _assessmentErrorMessage = null;
    }
    if (cachedClassroomExercise != null) {
      _classroomExerciseExercises = _submittedClassroomExercise(
        cachedClassroomExercise,
      );
      _classroomExerciseErrorMessage = null;
    } else {
      _classroomExerciseExercises = const <ClassroomExercise>[];
      _classroomExerciseErrorMessage = null;
    }

    _isLoadingAssessments = cachedQuizzes == null && shouldRefreshAssessments;
    _isLoadingClassroomExercise =
        cachedClassroomExercise == null && shouldRefreshClassroomExercise;
    _notifyIfAlive();

    await Future.wait<void>([
      if (shouldRefreshAssessments)
        _refreshAssessments(
          requestId: requestId,
          profileId: profileId,
          forceRefresh: forceRefresh || cachedQuizzes != null,
        ),
      if (shouldRefreshClassroomExercise)
        _refreshClassroomExercise(
          requestId: requestId,
          profileId: profileId,
          forceRefresh: forceRefresh || cachedClassroomExercise != null,
        ),
    ]);
  }

  Future<void> _refreshAssessments({
    required int requestId,
    required int profileId,
    required bool forceRefresh,
  }) async {
    try {
      final quizzes = await QuizCache.loadList(
        service: _quizService,
        profileId: profileId,
        forceRefresh: forceRefresh,
      );
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _assessmentQuizzes = _assessmentHistoryQuizzes(quizzes);
      _assessmentErrorMessage = null;
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _assessmentErrorMessage = _assessmentHistoryErrorMessage(error);
    } finally {
      if (_isCurrentRequest(requestId)) {
        _isLoadingAssessments = false;
        _notifyIfAlive();
      }
    }
  }

  Future<void> _refreshClassroomExercise({
    required int requestId,
    required int profileId,
    required bool forceRefresh,
  }) async {
    try {
      final exercises = await _loadSubmittedClassroomExercise(
        profileId,
        forceRefresh: forceRefresh,
      );
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _classroomExerciseExercises = exercises;
      _classroomExerciseErrorMessage = null;
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _classroomExerciseErrorMessage = _classroomExerciseHistoryErrorMessage(
        error,
      );
    } finally {
      if (_isCurrentRequest(requestId)) {
        _isLoadingClassroomExercise = false;
        _notifyIfAlive();
      }
    }
  }

  bool _isCurrentRequest(int requestId) =>
      !_disposed && requestId == _loadRequestId;

  Future<List<ClassroomExercise>> _loadSubmittedClassroomExercise(
    int profileId, {
    bool forceRefresh = false,
  }) async {
    final exercises =
        await QuizHistoryClassroomExerciseCache.loadSubmittedClassroomExercise(
          classroomService: _classroomService,
          assignmentService: _assignmentService,
          profileId: profileId,
          forceRefresh: forceRefresh,
        );
    return _submittedClassroomExercise(exercises);
  }

  List<GeneratedQuiz> _assessmentHistoryQuizzes(List<GeneratedQuiz> quizzes) {
    return quizzes.where(historyIsAssessmentQuiz).toList(growable: false)
      ..sort(historyCompareQuizDescending);
  }

  List<ClassroomExercise> _submittedClassroomExercise(
    List<ClassroomExercise> exercises,
  ) {
    return exercises
        .where(historyIsSubmittedClassroomExercise)
        .toList(growable: false)
      ..sort(historyCompareClassroomExerciseDescending);
  }

  String _assessmentHistoryErrorMessage(Object error) {
    return error is QuizException
        ? error.message
        : AppStrings.current(AppKeys.historyLoadFailed);
  }

  String _classroomExerciseHistoryErrorMessage(Object error) {
    if (error is ClassroomException) {
      return error.message;
    }
    if (error is ClassroomExerciseException) {
      return error.message;
    }
    return AppStrings.current(AppKeys.studentClassroomExerciseLoadFailed);
  }

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
