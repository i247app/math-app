import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/application/errors/classroom_exception.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/quiz/data/cache/quiz_cache.dart';
import 'package:numi/features/quiz/data/cache/quiz_history_homework_cache.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/application/errors/quiz_exception.dart';
import 'package:numi/features/quiz/application/read_models/history_compare_homework_descending.dart';
import 'package:numi/features/quiz/application/read_models/history_compare_quiz_descending.dart';
import 'package:numi/features/quiz/application/read_models/history_is_assessment_quiz.dart';
import 'package:numi/features/quiz/application/read_models/history_is_submitted_homework.dart';
import 'package:numi/features/homework/application/errors/classroom_exercise_exception.dart';

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
  List<ClassroomExercise> _homeworkExercises = const <ClassroomExercise>[];
  bool _isLoadingAssessments = true;
  bool _isLoadingHomework = true;
  String? _assessmentErrorMessage;
  String? _homeworkErrorMessage;
  int _loadRequestId = 0;
  bool _disposed = false;

  List<GeneratedQuiz> get assessmentQuizzes => _assessmentQuizzes;
  List<ClassroomExercise> get homeworkExercises => _homeworkExercises;
  bool get isLoadingAssessments => _isLoadingAssessments;
  bool get isLoadingHomework => _isLoadingHomework;
  String? get assessmentErrorMessage => _assessmentErrorMessage;
  String? get homeworkErrorMessage => _homeworkErrorMessage;

  Future<void> loadHistory({
    required int? profileId,
    bool forceRefresh = false,
  }) async {
    final requestId = ++_loadRequestId;
    if (profileId == null) {
      final message = AppStrings.current(AppKeys.noAccountForHistory);
      _isLoadingAssessments = false;
      _isLoadingHomework = false;
      _assessmentErrorMessage = message;
      _homeworkErrorMessage = message;
      _assessmentQuizzes = const <GeneratedQuiz>[];
      _homeworkExercises = const <ClassroomExercise>[];
      _notifyIfAlive();
      return;
    }

    final cachedQuizzes = QuizCache.peekList(profileId: profileId);
    final cachedHomework = QuizHistoryHomeworkCache.peekSubmittedHomework(
      profileId,
    );
    final shouldRefreshAssessments =
        forceRefresh || !QuizCache.isListFresh(profileId: profileId);
    final shouldRefreshHomework =
        forceRefresh || !QuizHistoryHomeworkCache.isFresh(profileId);

    if (cachedQuizzes != null) {
      _assessmentQuizzes = _assessmentHistoryQuizzes(cachedQuizzes);
      _assessmentErrorMessage = null;
    } else {
      _assessmentQuizzes = const <GeneratedQuiz>[];
      _assessmentErrorMessage = null;
    }
    if (cachedHomework != null) {
      _homeworkExercises = _submittedHomework(cachedHomework);
      _homeworkErrorMessage = null;
    } else {
      _homeworkExercises = const <ClassroomExercise>[];
      _homeworkErrorMessage = null;
    }

    _isLoadingAssessments = cachedQuizzes == null && shouldRefreshAssessments;
    _isLoadingHomework = cachedHomework == null && shouldRefreshHomework;
    _notifyIfAlive();

    await Future.wait<void>([
      if (shouldRefreshAssessments)
        _refreshAssessments(
          requestId: requestId,
          profileId: profileId,
          forceRefresh: forceRefresh || cachedQuizzes != null,
        ),
      if (shouldRefreshHomework)
        _refreshHomework(
          requestId: requestId,
          profileId: profileId,
          forceRefresh: forceRefresh || cachedHomework != null,
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

  Future<void> _refreshHomework({
    required int requestId,
    required int profileId,
    required bool forceRefresh,
  }) async {
    try {
      final exercises = await _loadSubmittedHomework(
        profileId,
        forceRefresh: forceRefresh,
      );
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _homeworkExercises = exercises;
      _homeworkErrorMessage = null;
    } catch (error) {
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _homeworkErrorMessage = _homeworkHistoryErrorMessage(error);
    } finally {
      if (_isCurrentRequest(requestId)) {
        _isLoadingHomework = false;
        _notifyIfAlive();
      }
    }
  }

  bool _isCurrentRequest(int requestId) =>
      !_disposed && requestId == _loadRequestId;

  Future<List<ClassroomExercise>> _loadSubmittedHomework(
    int profileId, {
    bool forceRefresh = false,
  }) async {
    final exercises = await QuizHistoryHomeworkCache.loadSubmittedHomework(
      classroomService: _classroomService,
      assignmentService: _assignmentService,
      profileId: profileId,
      forceRefresh: forceRefresh,
    );
    return _submittedHomework(exercises);
  }

  List<GeneratedQuiz> _assessmentHistoryQuizzes(List<GeneratedQuiz> quizzes) {
    return quizzes.where(historyIsAssessmentQuiz).toList(growable: false)
      ..sort(historyCompareQuizDescending);
  }

  List<ClassroomExercise> _submittedHomework(
    List<ClassroomExercise> exercises,
  ) {
    return exercises.where(historyIsSubmittedHomework).toList(growable: false)
      ..sort(historyCompareHomeworkDescending);
  }

  String _assessmentHistoryErrorMessage(Object error) {
    return error is QuizException
        ? error.message
        : AppStrings.current(AppKeys.historyLoadFailed);
  }

  String _homeworkHistoryErrorMessage(Object error) {
    if (error is ClassroomException) {
      return error.message;
    }
    if (error is ClassroomExerciseException) {
      return error.message;
    }
    return AppStrings.current(AppKeys.studentHomeworkLoadFailed);
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
