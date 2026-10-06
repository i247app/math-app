import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';

void main() {
  test(
    'generate and detail preserve the question type for fraction rendering',
    () {
      final generated = ExamQuestionDto.fromJson(<String, dynamic>{
        'question_name': r'Tinh \frac{1}{3}',
        'question_number': 1,
        'question_type': 'FRACTION',
        'answers': <Map<String, dynamic>>[
          <String, dynamic>{'label': 'A', 'content': r'\frac{1}{3}'},
        ],
      }).toModel();
      final detail = ExamDetailAnswerDto.fromJson(<String, dynamic>{
        'question_name': r'Tinh \frac{1}{3}',
        'question_number': 1,
        'question_type': 'FRACTION',
        'answers': <Map<String, dynamic>>[
          <String, dynamic>{'label': 'A', 'content': r'\frac{1}{3}'},
        ],
      }).toQuestionModel(questionNumber: 1);

      for (final question in [generated, detail]) {
        expect(question.questionType, 'FRACTION');
        expect(question.isFraction, isTrue);
        expect(question.answers.single.content, r'\frac{1}{3}');
      }
      expect(
        const ExamQuestionDto(
          questionName: '1 + 1',
          questionNumber: 1,
          answers: [],
          questionType: 'COUNT',
        ).toModel().isFraction,
        isFalse,
      );
    },
  );

  test('detail keeps negative option content when summary fields disagree', () {
    const detail = ExamDetailAnswerDto(
      questionNumber: 1,
      answers: <ExamAnswerDto>[
        ExamAnswerDto(label: 'A', content: '-5'),
        ExamAnswerDto(label: 'B', content: '-3'),
      ],
      rightAnswerLabel: 'A',
      rightAnswerContent: '5',
      selectedLabel: 'B',
      selectedContent: '3',
    );

    final question = detail.toQuestionModel(questionNumber: 1);

    expect(question.answers.map((answer) => answer.content), <String>[
      '-5',
      '-3',
    ]);
  });

  test('detail uses summary content for missing or empty options', () {
    const detail = ExamDetailAnswerDto(
      questionNumber: 1,
      answers: <ExamAnswerDto>[ExamAnswerDto(label: 'A', content: '')],
      rightAnswerLabel: 'A',
      rightAnswerContent: '-5',
      selectedLabel: 'B',
      selectedContent: '-3',
    );

    final question = detail.toQuestionModel(questionNumber: 1);

    expect(question.answers.map((answer) => answer.content), <String>[
      '-5',
      '-3',
    ]);
  });
}
