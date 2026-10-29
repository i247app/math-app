import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/grade_levels.dart';

void main() {
  test(
    'keeps per-question grade through generate, detail and image refresh',
    () {
      for (final grade in <int?>[0, 1, null]) {
        final generated = ExamQuestionDto.fromJson({
          'question_number': 1,
          'question_text': 'Con hãy đếm số quả táo.',
          'question_grade': grade,
          'options': <Map<String, dynamic>>[],
        }).toModel();
        final detail = ExamDetailAnswerDto.fromJson({
          'question_number': 1,
          'question_text': 'Con hãy đếm số quả táo.',
          'question_grade': grade,
        }).toQuestionModel(questionNumber: 1);
        for (final question in [generated, detail]) {
          expect(question.questionGrade, grade);
          expect(question.withRefreshedImages(null).questionGrade, grade);
        }
      }
    },
  );
  for (var apiLevel = 0; apiLevel <= 9; apiLevel++) {
    test('GRADE API level $apiLevel maps to display level ${apiLevel + 1}', () {
      final session = ExamStatsDto.fromJson({
        'exam_type': 'GRADE',
        'level': apiLevel,
        'total_questions': 10,
        'correct_number': 6,
        'skipped_number': 0,
        'score_percentage': 60,
        'in_progress_exams': [
          {
            'exam_type': 'GRADE',
            'level': apiLevel,
            'questions': <Map<String, dynamic>>[],
          },
        ],
      });
      final generated = GeneratedExamDto(
        examType: 'GRADE',
        level: apiLevel,
        questions: const [],
      ).toModel();
      final fromSession = const GeneratedExamDto(questions: [])
          .toModel(stats: session);
      final stats = session.toModel();
      final levels = GradeLevels.fromJson({
        'latest_level': apiLevel,
        'max_level': apiLevel,
      });

      expect(generated.level, apiLevel + 1);
      expect(fromSession.examType, isNull);
      expect(fromSession.level, isNull);
      expect(stats.level, apiLevel + 1);
      expect(stats.inProgressExams.single.level, apiLevel + 1);
      expect(stats.inProgressExams.single.examType, examTypeGrade);
      expect(levels.latestLevel, apiLevel + 1);
      expect(levels.maxLevel, apiLevel + 1);
    });
  }

  for (final type in [examTypeAssessment, examTypePractice]) {
    test('$type keeps the original API level', () {
      final exam = GeneratedExamDto(
        examType: type,
        level: 5,
        questions: const [],
      ).toModel();
      expect(exam.level, 5);
    });
  }

  test(
    'generate and detail preserve the question type for fraction rendering',
    () {
      final generated = ExamQuestionDto.fromJson(<String, dynamic>{
        'question_text': r'Tinh \frac{1}{3}',
        'question_number': 1,
        'render_type': 'FRACTION',
        'options': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'A', 'text': r'\frac{1}{3}'},
        ],
      }).toModel();
      final detail = ExamDetailAnswerDto.fromJson(<String, dynamic>{
        'question_text': r'Tinh \frac{1}{3}',
        'question_number': 1,
        'render_type': 'FRACTION',
        'options': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'A', 'text': r'\frac{1}{3}'},
        ],
      }).toQuestionModel(questionNumber: 1);

      for (final question in [generated, detail]) {
        expect(question.renderType, 'FRACTION');
        expect(question.isFraction, isTrue);
        expect(question.options.single.text, r'\frac{1}{3}');
      }
      expect(
        const ExamQuestionDto(
          questionText: '1 + 1',
          questionNumber: 1,
          options: [],
          renderType: 'COUNT',
        ).toModel().isFraction,
        isFalse,
      );
    },
  );

  test('detail keeps negative option content when summary fields disagree', () {
    const detail = ExamDetailAnswerDto(
      questionNumber: 1,
      options: <ExamAnswerDto>[
        ExamAnswerDto(id: 'A', text: '-5'),
        ExamAnswerDto(id: 'B', text: '-3'),
      ],
      rightOptionIds: ['A'],
      rightAnswerText: '5',
      childOptionIds: ['B'],
      childAnswerText: '3',
    );

    final question = detail.toQuestionModel(questionNumber: 1);

    expect(question.options.map((answer) => answer.text), <String>['-5', '-3']);
  });

  test('detail preserves empty options and separate answer summaries', () {
    const detail = ExamDetailAnswerDto(
      questionNumber: 1,
      options: <ExamAnswerDto>[ExamAnswerDto(id: 'A', text: '')],
      rightOptionIds: ['A'],
      rightAnswerText: '-5',
      childOptionIds: ['B'],
      childAnswerText: '-3',
    );

    final question = detail.toQuestionModel(questionNumber: 1);

    expect(question.options.map((answer) => answer.text), <String>['']);
    expect(question.reviewCorrectText, '-5');
    expect(question.reviewChildText, '-3');
  });
}
