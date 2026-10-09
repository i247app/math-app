import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/helpers/api_date_time.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/helpers/exam_review_formatters.dart';
import 'package:numi/features/exam/helpers/history_exam_helpers.dart';
import 'package:numi/features/exam/helpers/parent_assessment_display_helpers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/notifications/helpers/notification_display_helpers.dart';
import 'package:numi/features/notifications/models/notification.dart';

void main() {
  const compact = '20260927071430.940271';
  final utc = DateTime.utc(2026, 9, 27, 7, 14, 30, 940, 271);

  test('compact timestamp is UTC and retains microseconds', () {
    final parsed = tryParseApiDateTime('  $compact  ')!;
    expect(parsed, utc);
    expect(parsed.isUtc, isTrue);
    expect(parsed.microsecond, 271);
    expect(parsed.toLocal().toUtc(), utc);
  });

  for (final entry in [
    (text: '20260927071430', microseconds: 0),
    (text: '20260927071430.9', microseconds: 900000),
    (text: '20260927071430.940', microseconds: 940000),
    (text: '20260927071430.000001', microseconds: 1),
    (text: '20240229000000', microseconds: 0),
  ]) {
    test('compact format supports optional fraction (${entry.text})', () {
      final parsed = parseApiDateTime(entry.text);
      expect(parsed.isUtc, isTrue);
      expect(
        parsed.millisecond * 1000 + parsed.microsecond,
        entry.microseconds,
      );
    });
  }

  for (final invalid in <String?>[
    null,
    '',
    ' \n ',
    'not a date',
    '20260230071430.940271',
    '20260927071461.940271',
    '20261327071430',
    '20260927071430.',
  ]) {
    test('invalid timestamp is rejected ($invalid)', () {
      expect(tryParseApiDateTime(invalid), isNull);
      if (invalid != null) {
        expect(() => parseApiDateTime(invalid), throwsFormatException);
      }
    });
  }

  test('legacy ISO and explicit offsets remain supported', () {
    expect(parseApiDateTime('2026-09-27T07:14:30.940271Z'), utc);
    expect(parseApiDateTime('2026-09-27T14:14:30.940271+07:00'), utc);
    expect(parseApiDateTime('2026-09-27'), DateTime(2026, 9, 27));
  });

  final session = <String, dynamic>{
    'esess_id': 99,
    'correct_number': 5,
    'score_percentage': 50,
    'skipped_number': 0,
    'total_questions': 10,
    'create_dt': compact,
    'ended_dt': compact,
    'last_submitted_dt': compact,
  };

  test('session DTO parses all compact date fields as UTC', () {
    final dto = ExamStatsDto.fromJson(session);
    final model = dto.toModel();
    for (final date in [model.createDt, model.endedDt, model.lastSubmittedDt]) {
      expect(date, utc);
      expect(date!.isUtc, isTrue);
    }
  });

  test('submit and detail responses read exam_session, not stats', () {
    final response = <String, dynamic>{
      'mstatus': 200,
      'exam_session': session,
      'stats': {...session, 'esess_id': 1},
    };
    expect(
      SubmitExamResponseDto.fromJson(response).examSession?.userExamId,
      99,
    );
    expect(
      ExamDetailResponseDto.fromJson(response).examSession?.userExamId,
      99,
    );
    expect(
      SubmitExamResponseDto.fromJson(response).toJson(),
      contains('exam_session'),
    );
    expect(
      ExamDetailResponseDto.fromJson(response).toJson(),
      isNot(contains('stats')),
    );
  });

  test('chart progress parses compact dates', () {
    final model = ExamProgressResponseDto.fromJson({
      'mstatus': 200,
      'from_dt': compact,
      'to_dt': compact,
      'series': [
        {
          'last_submitted_dt': compact,
          'correct_number': 5,
          'esess_id': 99,
          'score': 5,
          'score_pct': 50,
          'sequence': 1,
          'total_questions': 10,
        },
      ],
    }).toModel();
    expect(model.fromDt, utc);
    expect(model.toDt, utc);
    expect(model.series.single.completedDt, utc);
  });

  test('exam date and time labels use the device timezone', () {
    final local = utc.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    final parts = parentAssessmentDateParts(compact);
    expect(parts.dt, '${two(local.day)}/${two(local.month)}/${local.year}');
    expect(parts.tm, '${two(local.hour)}:${two(local.minute)}');
    expect(
      examReviewTimeLabel(
        const GeneratedExam(createDt: compact, questions: []),
      ),
      parts.tm,
    );
    expect(historyDateValue(compact), local);
  });

  test('notification timestamps are not mistaken for epoch values', () {
    expect(notificationDate(const NotificationModel(createDt: compact)), utc);
    expect(
      notificationDate(const NotificationModel(createDt: '20260927071430')),
      DateTime.utc(2026, 9, 27, 7, 14, 30),
    );
  });
}
