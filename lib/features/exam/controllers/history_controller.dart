import 'package:flutter/foundation.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_strings.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_history_classroom_exercise_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/helpers/history_compare_classroom_exercise_descending.dart';
import 'package:numi/features/exam/helpers/history_compare_exam_descending.dart';
import 'package:numi/features/exam/helpers/history_is_assessment_exam.dart';
import 'package:numi/features/exam/helpers/history_is_submitted_classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';

class HistoryController extends ChangeNotifier {
  HistoryController({
    required ExamService examService,
    required ClassroomService classroomService,
    required ClassroomExerciseService assignmentService,
  }) : _examService = examService,
       _classroomService = classroomService,
       _assignmentService = assignmentService;

  final ExamService _examService;
  final ClassroomService _classroomService;
  final ClassroomExerciseService _assignmentService;

  List<GeneratedExam> _assessmentExams = const <GeneratedExam>[];
  List<ClassroomExercise> _classroomExerciseExercises =
      const <ClassroomExercise>[];
  bool _isLoadingAssessments = true;
  bool _isLoadingClassroomExercise = true;
  String? _assessmentErrorMessage;
  String? _classroomExerciseErrorMessage;
  int _loadRequestId = 0;
  bool _disposed = false;

  List<GeneratedExam> get assessmentExams => _assessmentExams;
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
      _assessmentExams = const <GeneratedExam>[];
      _classroomExerciseExercises = const <ClassroomExercise>[];
      _notifyIfAlive();
      return;
    }

    final cachedExams = ExamCache.peekList(profileId: profileId);
    final cachedClassroomExercise =
        ExamHistoryClassroomExerciseCache.peekSubmittedClassroomExercise(
          profileId,
        );
    final shouldRefreshAssessments =
        forceRefresh || !ExamCache.isListFresh(profileId: profileId);
    final shouldRefreshClassroomExercise =
        forceRefresh || !ExamHistoryClassroomExerciseCache.isFresh(profileId);

    if (cachedExams != null) {
      _assessmentExams = _assessmentHistoryExams(cachedExams);
      _assessmentErrorMessage = null;
    } else {
      _assessmentExams = const <GeneratedExam>[];
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

    _isLoadingAssessments = cachedExams == null && shouldRefreshAssessments;
    _isLoadingClassroomExercise =
        cachedClassroomExercise == null && shouldRefreshClassroomExercise;
    _notifyIfAlive();

    await Future.wait<void>([
      if (shouldRefreshAssessments)
        _refreshAssessments(
          requestId: requestId,
          profileId: profileId,
          forceRefresh: forceRefresh || cachedExams != null,
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
      final exams = await ExamCache.loadList(
        service: _examService,
        profileId: profileId,
        forceRefresh: forceRefresh,
      );
      if (!_isCurrentRequest(requestId)) {
        return;
      }
      _assessmentExams = _assessmentHistoryExams(exams);
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
        await ExamHistoryClassroomExerciseCache.loadSubmittedClassroomExercise(
          classroomService: _classroomService,
          assignmentService: _assignmentService,
          profileId: profileId,
          forceRefresh: forceRefresh,
        );
    return _submittedClassroomExercise(exercises);
  }

  List<GeneratedExam> _assessmentHistoryExams(List<GeneratedExam> exams) {
    return exams.where(historyIsAssessmentExam).toList(growable: false)
      ..sort(historyCompareExamDescending);
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
    return error is ExamException
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
