import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/home/data/home_layout_api_models.dart';
import 'package:numi/features/home/data/home_layout_conversion.dart';
import 'package:numi/features/home/helpers/home_layout_helpers.dart';

void main() {
  test('home layout reads exam link identity and renamed status', () {
    final response = HomeLayoutResponseDto.fromJson(<String, dynamic>{
      'mstatus': 200,
      'home': <String, dynamic>{
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'elink_id': 41,
            'exam_id': 7,
            'esess_id': 99,
            'exam_status': 'ACTIVE',
            'elink_status': 'IN_PROGRESS',
            'esess_status': 'ACTIVE',
            'title': 'Assessment',
          },
        ],
      },
    });

    final exam = response.home!.toModel().exams.single;
    expect(exam.examId, 41);
    expect(exam.aiExamId, 7);
    expect(exam.userExamId, 99);
    expect(exam.examStatus, 'ACTIVE');
    expect(exam.elinkStatus, 'IN_PROGRESS');
    expect(exam.esessStatus, 'ACTIVE');

    final listedExam = examsFromLayoutExams(
      response.home!.toModel().exams,
    ).single;
    expect(listedExam.userAiExamId, 41);
    expect(listedExam.aiExamId, 7);
    expect(listedExam.userExamId, 99);
    expect(listedExam.examStatus, 'IN_PROGRESS');
  });
}
