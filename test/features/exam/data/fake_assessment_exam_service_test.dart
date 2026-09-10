import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/fake_assessment_exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';

void main() {
  test('generates and grades a complete local assessment', () async {
    final service = FakeAssessmentExamService(delegate: _UnusedExamService());

    final generated = await service.generateAssessmentExam(
      gradeLabel: 'Lớp 3',
      profileId: 42,
    );

    expect(generated.examId, isNotNull);
    expect(generated.grade, 3);
    expect(generated.profileId, 42);
    expect(generated.questions, hasLength(10));

    final submitted = await service.submitExam(
      examId: generated.examId!,
      profileId: 42,
      answers: <SubmitExamAnswer>[
        for (final question in generated.questions)
          SubmitExamAnswer(
            questionNumber: question.questionNumber,
            label: question.rightAnswer!,
          ),
      ],
    );

    expect(submitted.examStatus, 'SUBMITTED');
    expect(submitted.grading?.correctNumber, 10);
    expect(submitted.grading?.scorePercentage, 100);
    expect(submitted.answers, hasLength(10));
  });
}

class _UnusedExamService implements ExamService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
