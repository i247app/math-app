import 'package:flutter/foundation.dart';

import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/features/exam/controllers/placement_result_state.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/assessment_progress_chart_data.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/placement_result_config.dart';

/// Loads result history and generates the configured next exam.
/// Navigation, haptics and error presentation belong to the screen.
class PlacementResultController extends ChangeNotifier {
  PlacementResultController({
    required ExamService examService,
    required this.grade,
    required int correctAnswers,
    required int totalQuestions,
    this.examType = examTypeAssessment,
    this.level,
    this.profileId,
    this.userExamId,
    this.previousGrade,
  }) : _examService = examService,
       totalQuestions = totalQuestions.clamp(0, 1000000),
       correctAnswers = correctAnswers.clamp(
         0,
         totalQuestions.clamp(0, 1000000),
       ),
       config = PlacementResultConfig.forExamType(examType) {
    _state = PlacementResultState(
      chart: _localChart(),
      progressResolved: !config.showsAssessmentChart || profileId == null,
    );
  }

  final ExamService _examService;
  final SessionCacheScope _cacheScope = SessionCacheScope.current;
  final int grade;
  final int? level;
  final int correctAnswers;
  final int totalQuestions;
  final String examType;
  final int? profileId;
  final int? userExamId;
  final int? previousGrade;
  final PlacementResultConfig config;
  late PlacementResultState _state;
  bool _initialized = false;
  bool _disposed = false;

  PlacementResultState get state => _state;

  bool get _isCurrent => !_disposed && _cacheScope.isCurrent;

  AssessmentProgressChartData _localChart() =>
      AssessmentProgressChartData.result(
        grade: grade,
        previousGrade: config.showsAssessmentChart ? previousGrade : null,
      );

  Future<void> initialize() async {
    if (!_isCurrent || _initialized) return;
    _initialized = true;
    final resultProfileId = profileId;
    if (!config.showsAssessmentChart || resultProfileId == null) return;
    var chart = _localChart();
    try {
      final toDt = DateTime.now();
      final progress = await _examService.getExamProgress(
        profileId: resultProfileId,
        fromDt: toDt.subtract(const Duration(days: 7)),
        toDt: toDt,
        examType: examType,
      );
      chart = AssessmentProgressChartData.forResult(
        progress,
        grade: grade,
        userExamId: userExamId,
        previousGrade: previousGrade,
      );
    } catch (_) {
      // Fall back to the submitted result when history is unavailable.
    }
    if (!_isCurrent) return;
    _state = _state.copyWith(chart: chart, progressResolved: true);
    notifyListeners();
  }

  Future<GeneratedExam?> generateNextExam() async {
    final action = config.generationAction;
    if (!_isCurrent || _state.isGenerating || action == null) return null;
    _state = _state.copyWith(isGenerating: true);
    notifyListeners();
    try {
      final generated = await _examService.generateAssessmentExam(
        examType: action.examType,
        gradeLabel: AssessmentFlowPolicy.gradeLabel(_state.grade),
        level: (level ?? 1).clamp(1, 10),
        profileId: profileId,
      );
      if (!_isCurrent) return null;
      ExamCache.seedDetail(generated);
      return generated;
    } catch (_) {
      if (!_isCurrent) return null;
      _state = _state.copyWith(isGenerating: false);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
