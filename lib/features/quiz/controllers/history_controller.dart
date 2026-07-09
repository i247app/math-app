import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/quiz_models.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/quiz/cache/quiz_cache.dart';
import 'package:numi/features/quiz/cache/quiz_history_homework_cache.dart';
import 'package:numi/features/quiz/quiz_api.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_compare_homework_descending.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_compare_quiz_descending.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_is_assessment_quiz.dart';
import 'package:numi/features/quiz/widgets/history_tab/history_is_submitted_homework.dart';

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
  bool _isLoading = true;
  String? _assessmentErrorMessage;
  String? _homeworkErrorMessage;
  int _loadRequestId = 0;
  bool _disposed = false;

  List<GeneratedQuiz> get assessmentQuizzes => _assessmentQuizzes;
  List<ClassroomExercise> get homeworkExercises => _homeworkExercises;
  bool get isLoading => _isLoading;
  String? get assessmentErrorMessage => _assessmentErrorMessage;
  String? get homeworkErrorMessage => _homeworkErrorMessage;

  Future<void> loadHistory({
    required int? profileId,
    bool forceRefresh = false,
  }) async {
    final requestId = ++_loadRequestId;
    if (profileId == null) {
      final message = AppStrings.current(AppKeys.noAccountForHistory);
      _isLoading = false;
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
    final hasCachedData = cachedQuizzes != null || cachedHomework != null;
    if (hasCachedData) {
      if (cachedQuizzes != null) {
        _assessmentQuizzes = _assessmentHistoryQuizzes(cachedQuizzes);
        _assessmentErrorMessage = null;
      }
      if (cachedHomework != null) {
        _homeworkExercises = _submittedHomework(cachedHomework);
        _homeworkErrorMessage = null;
      }
      _isLoading = false;
      _notifyIfAlive();
    } else {
      _isLoading = true;
      _assessmentErrorMessage = null;
      _homeworkErrorMessage = null;
      _notifyIfAlive();
    }

    final shouldRefresh =
        forceRefresh ||
        !QuizCache.isListFresh(profileId: profileId) ||
        !QuizHistoryHomeworkCache.isFresh(profileId);
    if (!shouldRefresh) {
      return;
    }

    var assessmentQuizzes = const <GeneratedQuiz>[];
    var homeworkExercises = const <ClassroomExercise>[];
    String? assessmentError;
    String? homeworkError;

    await Future.wait<void>([
      QuizCache.loadList(
            service: _quizService,
            profileId: profileId,
            forceRefresh: forceRefresh || cachedQuizzes != null,
          )
          .then((quizzes) {
            assessmentQuizzes = _assessmentHistoryQuizzes(quizzes);
          })
          .catchError((Object error) {
            assessmentError = _assessmentHistoryErrorMessage(error);
          }),
      _loadSubmittedHomework(
            profileId,
            forceRefresh: forceRefresh || cachedHomework != null,
          )
          .then((exercises) {
            homeworkExercises = exercises;
          })
          .catchError((Object error) {
            homeworkError = _homeworkHistoryErrorMessage(error);
          }),
    ]);

    if (_disposed || requestId != _loadRequestId) {
      return;
    }
    _assessmentQuizzes = assessmentQuizzes;
    _homeworkExercises = homeworkExercises;
    _assessmentErrorMessage = assessmentError;
    _homeworkErrorMessage = homeworkError;
    _isLoading = false;
    notifyListeners();
  }

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
