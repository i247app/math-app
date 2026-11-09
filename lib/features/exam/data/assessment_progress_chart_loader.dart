import 'package:numi/core/debug/app_logger.dart';
import 'package:numi/core/helpers/api_date_time.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/assessment_progress_chart_data.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Home and welcome show recent attempts regardless of how long ago they were.
Future<AssessmentProgressChartData> loadRecentAssessmentChart(
  ExamService service, {
  required int profileId,
  String? profileCreatedAt,
}) async {
  // The API rejects ranges longer than two years (mstatus 13719). Query
  // backwards in valid windows and stop as soon as seven usable points exist.
  const window = Duration(days: 730);
  var toDt = DateTime.now();
  final createdAt = tryParseApiDateTime(profileCreatedAt)?.toLocal();
  // Older history is bounded by profile creation. Without that metadata, make
  // one valid request instead of scanning decades for a profile with no exams.
  final historyStart = createdAt != null && createdAt.isBefore(toDt)
      ? createdAt.subtract(const Duration(days: 1))
      : toDt.subtract(window);
  final points = <int, ExamProgressPoint>{};
  var chart = AssessmentProgressChartData.empty;
  while (toDt.isAfter(historyStart)) {
    final windowStart = toDt.subtract(window);
    final fromDt = windowStart.isBefore(historyStart)
        ? historyStart
        : windowStart;
    try {
      final progress = await service.getExamProgress(
        profileId: profileId,
        fromDt: fromDt,
        toDt: toDt,
      );
      // Adjacent inclusive date ranges can return the same boundary attempt.
      for (final point in progress.series) {
        points.putIfAbsent(point.examId, () => point);
      }
      chart = AssessmentProgressChartData.fromProgress(
        ExamProgressResponse(mstatus: 200, series: points.values.toList()),
      );
    } on Exception catch (error) {
      AppLogger.warning('CHART', 'Assessment history request failed: $error');
      // An older-window failure must not erase the recent results we loaded.
      if (chart.hasProgress) return chart;
      rethrow;
    }
    if (chart.hasProgress &&
        chart.testNumbers.length >=
            AssessmentProgressChartData.recentPointLimit) {
      return chart;
    }
    toDt = fromDt;
  }
  return chart;
}
