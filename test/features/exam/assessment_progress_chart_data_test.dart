import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/models/assessment_progress_chart_data.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  test(
    'filters incomplete or ungraded attempts and orders by sequence/date',
    () {
      final points = [
        _point(3, 8, sequence: 2, day: 3, status: ' submitted '),
        _point(2, 2, sequence: 2, day: 2, status: null),
        _point(1, -1, sequence: 1),
        _point(4, 4, sequence: 3, status: 'IN_PROGRESS'),
        _point(5, null, sequence: 4),
        _point(6, 4, sequence: 5, status: ''),
      ];
      final chart = AssessmentProgressChartData.fromProgress(_progress(points));

      expect(chart.finalGrade, 5);
      expect(chart.previousGrades, [0, 2]);
      expect(chart.testNumbers, [1, 2, 2]);
      expect(chart.lastSubmittedAt, DateTime.utc(2026, 1, 3));
      expect(chart.hasProgress, isTrue);
      expect(points.first.examId, 3); // Mapping must not reorder API data.
      expect(() => chart.previousGrades.add(4), throwsUnsupportedError);
      expect(() => chart.testNumbers.clear(), throwsUnsupportedError);
    },
  );

  test(
    'home/intro history retains every completed point in the API window',
    () {
      final chart = AssessmentProgressChartData.fromProgress(
        _progress([
          for (var i = 1; i <= 12; i++) _point(i, i % 6, sequence: i),
        ]),
      );
      expect(chart.previousGrades.length, 11);
      expect(chart.testNumbers, List.generate(12, (i) => i + 1));
    },
  );

  test('result keeps six preceding points and excludes later attempts', () {
    final chart = AssessmentProgressChartData.forResult(
      _progress([
        for (var i = 12; i >= 1; i--) _point(i, i % 6, sequence: i * 2),
      ]),
      grade: 5,
      userExamId: 10,
    );
    expect(chart.finalGrade, 4);
    expect(chart.previousGrades, [4, 5, 0, 1, 2, 3]);
    expect(chart.testNumbers, [8, 10, 12, 14, 16, 18, 20]);
    expect(chart.firstTestNumber, 14);
    expect(chart.lastSubmittedAt, DateTime.utc(2026, 1, 20));
  });

  test(
    'result appends the local grade when the API has not included it yet',
    () {
      final chart = AssessmentProgressChartData.forResult(
        _progress([for (var i = 1; i <= 8; i++) _point(i, i % 6, sequence: i)]),
        grade: 2,
        userExamId: 99,
        previousGrade: 5,
      );
      expect(chart.finalGrade, 2);
      expect(chart.previousGrades, [3, 4, 5, 0, 1, 2]);
      expect(chart.testNumbers, [3, 4, 5, 6, 7, 8, 9]);
      expect(chart.lastSubmittedAt, isNull);
    },
  );

  test('result without an attempt ID uses the latest completed API point', () {
    final chart = AssessmentProgressChartData.forResult(
      _progress([_point(1, 2, sequence: 3), _point(2, 4, sequence: 5)]),
      grade: 1,
      previousGrade: 0,
    );
    expect(chart.finalGrade, 4);
    expect(chart.previousGrades, [2]);
    expect(chart.testNumbers, [3, 5]);
  });

  test(
    'empty or unusable progress preserves the submitted result fallback',
    () {
      final progress = _progress([_point(1, 3, sequence: 1, status: 'ACTIVE')]);
      final home = AssessmentProgressChartData.fromProgress(progress);
      expect(home.finalGrade, 0);
      expect(home.previousGrades, isEmpty);
      expect(home.testNumbers, [1]);
      expect(home.hasProgress, isFalse);

      final result = AssessmentProgressChartData.forResult(
        progress,
        grade: 2,
        previousGrade: 3,
      );
      expect(result.finalGrade, 2);
      expect(result.previousGrades, [3]);
      expect(result.testNumbers, [1, 2]);
      expect(result.lastSubmittedAt, isNull);
      expect(result.hasProgress, isFalse);
    },
  );
}

ExamProgressResponse _progress(List<ExamProgressPoint> points) =>
    ExamProgressResponse(mstatus: 200, series: points);

ExamProgressPoint _point(
  int id,
  int? grade, {
  required int sequence,
  int? day,
  String? status = 'COMPLETE',
}) => ExamProgressPoint(
  completedDt: DateTime.utc(2026, 1, day ?? sequence),
  correctNumber: 5,
  examId: id,
  score: 10,
  scorePct: 100,
  sequence: sequence,
  totalQuestions: 5,
  grade: grade,
  status: status,
);
