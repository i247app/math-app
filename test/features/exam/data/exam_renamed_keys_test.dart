import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';

void main() {
  test('old exam title keys are ignored rather than used as aliases', () {
    final exam = GeneratedExamDto.fromJson({
      'ai_title': 'Old title',
      'ai_short_text': 'Old description',
      'questions': [],
    });
    final session = ExamStatsDto.fromJson({
      'ai_title': 'Old journey title',
      'ai_short_text': 'Old journey description',
      'correct_number': 0,
      'score_percentage': 0,
      'skipped_number': 0,
      'total_questions': 0,
    });
    expect(exam.title, isNull);
    expect(exam.shortText, isNull);
    expect(session.title, isNull);
    expect(session.shortText, isNull);
    for (final json in [exam.toJson(), session.toJson()]) {
      expect(json, isNot(contains('ai_title')));
      expect(json, isNot(contains('ai_short_text')));
    }
  });

  test('old question and review keys do not populate the new contract', () {
    expect(
      () => ExamQuestionDto.fromJson({
        'question_number': 1,
        'question_name': 'Old question',
        'question_type': 'ARITHMETIC',
        'answers': [
          {'label': 'A', 'content': '2'},
        ],
        'right_answer_label': 'A',
        'right_answer_content': '2',
      }),
      throwsA(isA<TypeError>()),
    );
    final detail = ExamDetailAnswerDto.fromJson({
      'question_number': 1,
      'question_name': 'Old question',
      'right_answer_label': 'A',
      'right_answer_content': '2',
      'selected_label': 'B',
      'selected_content': '3',
    });
    expect(detail.questionText, isNull);
    expect(detail.rightOptionIds, isEmpty);
    expect(detail.childOptionIds, isEmpty);
    expect(detail.rightAnswerText, isNull);
    expect(detail.childAnswerText, isNull);
  });

  test('exam records read renamed identity and status fields', () {
    final exam = GeneratedExamDto.fromJson(<String, dynamic>{
      'exam_id': 7,
      'elink_id': 41,
      'status': 'ACTIVE',
      'questions': <Map<String, dynamic>>[],
    });

    expect(exam.examId, 7);
    expect(exam.elinkId, 41);
    expect(exam.status, 'ACTIVE');
    expect(exam.toJson(), containsPair('status', 'ACTIVE'));
  });

  test('old status aliases and singular active exam are ignored', () {
    final exam = GeneratedExamDto.fromJson({
      'elink_status': 'IN_PROGRESS',
      'exam_status': 'ACTIVE',
      'esess_id': 99,
      'questions': [],
    });
    final session = ExamStatsDto.fromJson({
      'esess_status': 'ACTIVE',
      'correct_number': 0,
      'skipped_number': 0,
      'total_questions': 0,
      'in_progress_exam': {
        'elink_id': 41,
        'status': 'IN_PROGRESS',
        'questions': [],
      },
    });
    expect(exam.status, isNull);
    expect(exam.toJson(), isNot(contains('esess_id')));
    expect(session.status, isNull);
    expect(session.inProgressExams, isEmpty);
    expect(session.toJson(), isNot(contains('in_progress_exam')));
  });

  test('journey stats and detail lines read renamed fields', () {
    final stats = ExamStatsDto.fromJson(<String, dynamic>{
      'correct_number': 1,
      'score_percentage': 50,
      'skipped_number': 0,
      'total_questions': 2,
      'esess_id': 99,
      'status': 'COMPLETE',
    });
    final detail = ExamDetailAnswerDto.fromJson(<String, dynamic>{
      'question_number': 1,
      'elink_id': 41,
      'esess_ln_id': 18,
      'esess_ln_status': 'SUBMITTED',
    });

    expect(stats.esessId, 99);
    expect(stats.status, 'COMPLETE');
    expect(detail.elinkId, 41);
    expect(detail.userExamDetailId, 18);
    expect(detail.detailStatus, 'SUBMITTED');
  });
}
