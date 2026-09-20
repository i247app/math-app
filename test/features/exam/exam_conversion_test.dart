import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';

void main() {
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
