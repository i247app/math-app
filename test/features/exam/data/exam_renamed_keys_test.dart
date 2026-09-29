import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';

void main() {
  test('exam records read renamed identity and status fields', () {
    final exam = GeneratedExamDto.fromJson(<String, dynamic>{
      'exam_id': 7,
      'elink_id': 41,
      'esess_id': 99,
      'elink_status': 'ACTIVE',
      'questions': <Map<String, dynamic>>[],
    });

    expect(exam.aiExamId, 7);
    expect(exam.userAiExamId, 41);
    expect(exam.userExamId, 99);
    expect(exam.status, 'ACTIVE');
    expect(exam.toJson(), containsPair('elink_status', 'ACTIVE'));
  });

  test('journey stats and detail lines read renamed fields', () {
    final stats = ExamStatsDto.fromJson(<String, dynamic>{
      'correct_number': 1,
      'score_percentage': 50,
      'skipped_number': 0,
      'total_questions': 2,
      'esess_id': 99,
      'esess_status': 'COMPLETE',
    });
    final detail = ExamDetailAnswerDto.fromJson(<String, dynamic>{
      'question_number': 1,
      'elink_id': 41,
      'esess_ln_id': 18,
      'esess_ln_status': 'SUBMITTED',
    });

    expect(stats.userExamId, 99);
    expect(stats.status, 'COMPLETE');
    expect(detail.userAiExamId, 41);
    expect(detail.userExamDetailId, 18);
    expect(detail.detailStatus, 'SUBMITTED');
  });
}
