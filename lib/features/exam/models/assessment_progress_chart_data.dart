import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Chart-ready assessment history, independent of fetching and presentation.
class AssessmentProgressChartData {
  AssessmentProgressChartData._({
    required this.finalGrade,
    required List<int> previousGrades,
    required List<int> testNumbers,
    this.lastSubmittedAt,
    this.hasProgress = false,
  }) : previousGrades = List.unmodifiable(previousGrades),
       testNumbers = List.unmodifiable(testNumbers);

  static final empty = AssessmentProgressChartData.result(grade: 0);

  final int finalGrade;
  final List<int> previousGrades;
  final List<int> testNumbers;
  final DateTime? lastSubmittedAt;
  final bool hasProgress;

  int get firstTestNumber => testNumbers.last - previousGrades.length;

  /// Home and intro charts include all completed assessments in their window.
  factory AssessmentProgressChartData.fromProgress(
    ExamProgressResponse progress,
  ) {
    final points = _completedPoints(progress);
    if (points.isEmpty) return empty;
    return AssessmentProgressChartData._(
      finalGrade: AssessmentFlowPolicy.clampGrade(points.last.grade!),
      previousGrades: points
          .take(points.length - 1)
          .map((point) => AssessmentFlowPolicy.clampGrade(point.grade!))
          .toList(),
      testNumbers: points.map((point) => point.sequence).toList(),
      lastSubmittedAt: points.last.completedDt,
      hasProgress: true,
    );
  }

  /// A local result remains visible when progress is missing or unavailable.
  factory AssessmentProgressChartData.result({
    required int grade,
    int? previousGrade,
  }) => AssessmentProgressChartData._(
    finalGrade: AssessmentFlowPolicy.clampGrade(grade),
    previousGrades: previousGrade == null
        ? const []
        : [AssessmentFlowPolicy.clampGrade(previousGrade)],
    testNumbers: previousGrade == null ? const [1] : const [1, 2],
  );

  /// Result charts stop at the current attempt and keep six preceding points.
  /// If the API has not included that attempt yet, append the local result.
  factory AssessmentProgressChartData.forResult(
    ExamProgressResponse progress, {
    required int grade,
    int? userExamId,
    int? previousGrade,
  }) {
    final points = _completedPoints(progress);
    if (points.isEmpty) {
      return AssessmentProgressChartData.result(
        grade: grade,
        previousGrade: previousGrade,
      );
    }
    final currentIndex = userExamId == null
        ? points.length - 1
        : points.indexWhere((point) => point.examId == userExamId);
    final current = currentIndex >= 0 ? points[currentIndex] : null;
    final historyEnd = currentIndex >= 0 ? currentIndex : points.length;
    final historyStart = historyEnd > 6 ? historyEnd - 6 : 0;
    final history = points.sublist(historyStart, historyEnd);
    return AssessmentProgressChartData._(
      finalGrade: AssessmentFlowPolicy.clampGrade(current?.grade ?? grade),
      previousGrades: history
          .map((point) => AssessmentFlowPolicy.clampGrade(point.grade!))
          .toList(),
      testNumbers: [
        ...history.map((point) => point.sequence),
        current?.sequence ?? points.last.sequence + 1,
      ],
      lastSubmittedAt: current?.completedDt,
      hasProgress: true,
    );
  }

  static List<ExamProgressPoint> _completedPoints(
    ExamProgressResponse progress,
  ) {
    return progress.series.where((point) {
      final status = point.status?.trim().toUpperCase();
      return point.grade != null &&
          (status == null || status == 'COMPLETE' || status == 'SUBMITTED');
    }).toList()..sort((a, b) {
      final bySequence = a.sequence.compareTo(b.sequence);
      return bySequence != 0
          ? bySequence
          : a.completedDt.compareTo(b.completedDt);
    });
  }
}
