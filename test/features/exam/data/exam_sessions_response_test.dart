import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/helpers/parent_assessment_helpers.dart';

void main() {
  test('parses supplied complete and left active sessions', () {
    final json = jsonDecode(
      File('test/fixtures/exam_sessions_list_with_active.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final response = ExamStatsResponseDto.fromJson(json);
    expect(response.examSessions, hasLength(2));
    expect(response.toJson(), contains('exam_sessions'));
    expect(response.cursor?.hasNext, isFalse);
    expect(response.cursor?.hasPrev, isFalse);
    expect(response.cursor?.startCursor, isNotEmpty);
    expect(response.toJson()['cursor'], json['cursor']);

    final active = response.examSessions.first.toModel();
    expect(active.userExamId, 6);
    expect(active.status, 'ACTIVE');
    expect(active.scorePercentage, 0);
    expect(active.review, isNull);
    expect(isCompletedAssessmentStats(active), isFalse);
    final resumable = activeInProgressAssessmentExam(active)!;
    expect(resumable.userAiExamId, 8);
    expect(resumable.examStatus, 'IN_PROGRESS');
    expect(resumable.questions, hasLength(10));
    expect(resumable.shortText, 'Đếm, cộng trừ và quy luật số');

    final complete = response.examSessions.last.toModel();
    expect(complete.status, 'COMPLETE');
    expect(isCompletedAssessmentStats(complete), isTrue);
    expect(activeInProgressAssessmentExam(complete), isNull);
    expect(complete.review, 'Đã trả lời (2/15) câu đúng (13%).');
  });

  test('uses canonical status and keeps each sitting own text', () {
    final session = ExamStatsDto.fromJson({
      'esess_id': 6,
      'status': 'ACTIVE',
      'esess_status': 'COMPLETE',
      'esess_flag': false,
      'correct_number': 0,
      'skipped_number': 0,
      'total_questions': 0,
      'title': 'Session title',
      'short_text': 'Session description',
    });
    final dto = GeneratedExamDto.fromJson({
      'elink_id': 8,
      'exam_id': 80,
      'status': 'IN_PROGRESS',
      'elink_status': 'SUBMITTED',
      'title': 'Exam title',
      'short_text': 'Exam description',
      'questions': <Map<String, dynamic>>[],
    });
    final exam = dto.toModel(stats: session, userExamId: session.esessId);
    expect(session.status, 'ACTIVE');
    expect(session.esessId, 6);
    expect(session.esessFlag, isFalse);
    expect(session.toModel().passed, isFalse);
    expect(dto.elinkId, 8);
    expect(dto.examId, 80);
    expect(session.toJson(), containsPair('status', 'ACTIVE'));
    expect(exam.examStatus, 'IN_PROGRESS');
    expect(exam.userExamId, 6);
    expect(exam.userAiExamId, 8);
    expect(exam.examId, 8);
    expect(exam.aiExamId, 80);
    expect(exam.title, 'Exam title');
    expect(exam.shortText, 'Exam description');
    expect(dto.toJson(), containsPair('short_text', 'Exam description'));

    final missingSittingFields = const GeneratedExamDto(questions: [])
        .toModel(stats: session);
    expect(missingSittingFields.title, isNull);
    expect(missingSittingFields.shortText, isNull);
    expect(missingSittingFields.examStatus, isNull);
    expect(missingSittingFields.userExamId, isNull);
  });

  test('request DTOs serialize session and assigned-set IDs separately', () {
    const generate = GenerateExamRequest(
      profileId: 7,
      numQuestions: 10,
      examType: 'PRACTICE',
      grade: 0,
      level: 1,
      esessId: 6,
    );
    const submit = SubmitExamRequest(profileId: 7, elinkId: 8, answers: []);
    expect(generate.toJson(), containsPair('esess_id', 6));
    expect(generate.toJson(), isNot(contains('elink_id')));
    expect(submit.toJson(), {
      'profile_id': 7,
      'elink_id': 8,
      'answers': <Map<String, dynamic>>[],
    });
  });
}
