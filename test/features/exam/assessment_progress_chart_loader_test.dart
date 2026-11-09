import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/assessment_progress_chart_loader.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  test(
    'recent chart includes old history and selects seven completed attempts',
    () async {
      final now = DateTime.now().toUtc();
      final service = _HistoryService([
        for (var i = 12; i >= 1; i--)
          ExamProgressPoint(
            completedDt: now.subtract(Duration(days: (13 - i) * 400)),
            correctNumber: 5,
            examId: i,
            score: 10,
            scorePct: 100,
            sequence: i,
            totalQuestions: 5,
            grade: i % 6,
            status: 'COMPLETE',
          ),
        ExamProgressPoint(
          completedDt: now.subtract(const Duration(days: 1)),
          correctNumber: 0,
          examId: 13,
          score: 0,
          scorePct: 0,
          sequence: 13,
          totalQuestions: 5,
          grade: 4,
          status: 'IN_PROGRESS',
        ),
      ]);
      final chart = await loadRecentAssessmentChart(
        service,
        profileId: 42,
        profileCreatedAt: now
            .subtract(const Duration(days: 5000))
            .toIso8601String(),
      );

      expect(service.profileId, 42);
      expect(service.requests.length, greaterThan(1));
      expect(service.requests.first.$2.isBefore(now), isFalse);
      for (var i = 0; i < service.requests.length; i++) {
        final (from, to) = service.requests[i];
        expect(
          to.difference(from),
          lessThanOrEqualTo(const Duration(days: 730)),
        );
        if (i > 0) expect(to, service.requests[i - 1].$1);
      }
      expect(chart.testNumbers, [6, 7, 8, 9, 10, 11, 12]);
      expect(chart.previousGrades, [0, 1, 2, 3, 4, 5]);
      expect(chart.finalGrade, 0);
      expect(chart.lastSubmittedAt, now.subtract(const Duration(days: 400)));
    },
  );

  test(
    'missing profile creation makes only one valid empty-history request',
    () async {
      final service = _HistoryService([]);
      final chart = await loadRecentAssessmentChart(service, profileId: 42);
      expect(chart.hasProgress, isFalse);
      expect(service.requests, hasLength(1));
      expect(
        service.toDt!.difference(service.fromDt!),
        const Duration(days: 730),
      );
    },
  );

  test(
    'profile creation bounds requests and compact UTC timestamps are accepted',
    () async {
      final service = _HistoryService([]);
      final chart = await loadRecentAssessmentChart(
        service,
        profileId: 42,
        profileCreatedAt: '20261101000000.000000',
      );
      expect(chart.hasProgress, isFalse);
      expect(service.requests, hasLength(1));
      expect(service.fromDt!.toUtc(), DateTime.utc(2026, 10, 31));
    },
  );

  test('older-window errors retain already loaded chart data', () async {
    final now = DateTime.now();
    final service = _HistoryService([
      _point(1, now.subtract(const Duration(days: 10))),
      _point(2, now.subtract(const Duration(days: 5))),
    ], failOnRequest: 2);
    final chart = await loadRecentAssessmentChart(
      service,
      profileId: 42,
      profileCreatedAt: DateTime.utc(2000).toIso8601String(),
    );
    expect(service.requests, hasLength(2));
    expect(chart.hasProgress, isTrue);
    expect(chart.testNumbers, [1, 2]);
  });

  test(
    'initial request failure is propagated instead of becoming empty history',
    () async {
      final service = _HistoryService([], failOnRequest: 1);
      await expectLater(
        loadRecentAssessmentChart(service, profileId: 42),
        throwsA(isA<ExamException>()),
      );
      expect(service.requests, hasLength(1));
    },
  );

  test('stops once seven completed attempts are found', () async {
    final now = DateTime.now();
    final service = _HistoryService([
      for (var i = 1; i <= 12; i++)
        _point(i, now.subtract(Duration(days: 13 - i))),
    ]);
    final chart = await loadRecentAssessmentChart(
      service,
      profileId: 42,
      profileCreatedAt: DateTime.utc(2000).toIso8601String(),
    );
    expect(service.requests, hasLength(1));
    expect(chart.testNumbers, [6, 7, 8, 9, 10, 11, 12]);
  });
}

ExamProgressPoint _point(int id, DateTime date) => ExamProgressPoint(
  completedDt: date,
  correctNumber: 5,
  examId: id,
  score: 10,
  scorePct: 100,
  sequence: id,
  totalQuestions: 5,
  grade: id % 6,
  status: 'COMPLETE',
);

class _HistoryService implements ExamService {
  _HistoryService(this.points, {this.failOnRequest});

  final List<ExamProgressPoint> points;
  final int? failOnRequest;
  final requests = <(DateTime, DateTime)>[];
  int? profileId;
  DateTime? fromDt;
  DateTime? toDt;

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) async {
    this.profileId = profileId;
    this.fromDt = fromDt;
    this.toDt = toDt;
    requests.add((fromDt, toDt));
    if (toDt.difference(fromDt) > const Duration(days: 730)) {
      throw const ExamException('Invalid date range', status: 13719);
    }
    if (requests.length == failOnRequest) {
      throw const ExamException('History unavailable');
    }
    expect(examType, examTypeAssessment);
    return ExamProgressResponse(
      mstatus: 200,
      series: points
          .where(
            (point) =>
                !point.completedDt.isBefore(fromDt) &&
                !point.completedDt.isAfter(toDt),
          )
          .toList(),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
