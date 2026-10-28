import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/controllers/exam_attempt_controller.dart';
import 'package:numi/features/exam/controllers/review_detail_controller.dart';
import 'package:numi/features/exam/data/exam_api_models.dart';
import 'package:numi/features/exam/data/exam_cache.dart';
import 'package:numi/features/exam/data/exam_conversion.dart';
import 'package:numi/features/exam/data/exam_exception.dart';
import 'package:numi/features/exam/data/exam_image_refresher.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/exam_review_answers.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_answer_selection.dart';
import 'package:numi/features/exam/models/exam_attempt_answers.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_button.dart';
import 'package:numi/features/exam/widgets/assessment/assessment_answer_grid.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_list.dart';
import 'package:numi/features/exam/widgets/shared/exam_numeric_input.dart';

const _options = [
  {'id': 'Bank-B', 'text': '5'},
  {'id': 'bank-a', 'text': '4'},
  {'id': 'c', 'text': '3'},
];

ExamQuestion _question({String? kind, Map<String, dynamic>? correct}) =>
    ExamQuestionDto.fromJson({
      'question_number': 7,
      'question_text': '2 + 3 = ?',
      'render_type': 'ARITHMETIC',
      'question_kind': ?kind,
      'options': kind == 'NUMERIC_INPUT' ? [] : _options,
      'correct_answer': ?correct,
    }).toModel();

void main() {
  setUp(ExamCache.clear);
  tearDown(ExamCache.clear);

  test(
    'shuffled single choice defaults its kind and submits the exact server ID',
    () {
      final question = _question(
        correct: {
          'option_ids': ['Bank-B'],
        },
      );
      final answers = ExamAttemptAnswers()
        ..select(0, question, question.options.first, practice: false);
      final exam = GeneratedExam(questions: [question]);
      expect(question.questionKind, 'SINGLE_CHOICE');
      expect(answers.score(exam).correctCount, 1);
      expect(answers.submission(exam).single.toDto().toJson(), {
        'question_number': 7,
        'option_ids': ['Bank-B'],
      });
      expect(
        const ExamAnswerSelection(optionIds: ['bank-b']).isCorrect(question),
        isFalse,
      );
      expect(_question().correctOptionIds, isEmpty);
      expect(
        const ExamAnswerSelection(optionIds: ['Bank-B']).isCorrect(_question()),
        isNull,
      );
    },
  );

  test('multiple choice toggles IDs and requires exact set equality', () {
    final question = _question(
      kind: 'MULTIPLE_CHOICE',
      correct: {
        'option_ids': ['Bank-B', 'c'],
      },
    );
    final answers = ExamAttemptAnswers();
    final exam = GeneratedExam(questions: [question]);
    answers.select(0, question, question.options.last, practice: false);
    expect(answers.score(exam).correctCount, 0);
    answers.select(0, question, question.options.first, practice: false);
    expect(answers.score(exam).correctCount, 1);
    expect(answers.submission(exam).single.toDto().toJson(), {
      'question_number': 7,
      'option_ids': ['c', 'Bank-B'],
    });
    answers.select(0, question, question.options[1], practice: false);
    expect(answers.score(exam).correctCount, 0);
    for (final answer in question.options) {
      answers.select(0, question, answer, practice: false);
    }
    expect(answers.submission(exam), isEmpty);
    expect(answers.answeredCount, 0);
  });

  test('false answer key stays false and submits an option ID', () {
    final question = ExamQuestionDto.fromJson({
      'question_number': 3,
      'question_text': '2 > 3?',
      'question_kind': 'TRUE_FALSE',
      'options': [
        {'id': 'true', 'text': 'Đúng'},
        {'id': 'false', 'text': 'Sai'},
      ],
      'correct_answer': {'value': false},
    }).toModel();
    final answers = ExamAttemptAnswers()
      ..select(0, question, question.options.last, practice: false);
    final exam = GeneratedExam(questions: [question]);
    expect(question.correctOptionIds, ['false']);
    expect(answers.score(exam).correctCount, 1);
    expect(answers.submission(exam).single.toDto().toJson(), {
      'question_number': 3,
      'option_ids': ['false'],
    });
  });

  for (final value in ['0,5', '1/2', '0.5', '2/4', '-1/-2']) {
    test('numeric $value is graded by value and preserved in submission', () {
      final question = _question(
        kind: 'NUMERIC_INPUT',
        correct: {
          'values': ['0.5'],
        },
      );
      final answers = ExamAttemptAnswers()
        ..setNumericValue(0, question, value, practice: false);
      final exam = GeneratedExam(questions: [question]);
      expect(question.options, isEmpty);
      expect(answers.score(exam).correctCount, 1);
      expect(answers.submission(exam).single.toDto().toJson(), {
        'question_number': 7,
        'value': value,
      });
      final restored = ExamAttemptAnswers()
        ..restore(
          GeneratedExam(
            questions: [question],
            answers: answers.submission(exam),
          ),
        );
      expect(restored.selectedLabel(0, practice: false), value);
    });
  }

  for (final value in ['', '-', '1/', '1/0', 'NaN', '1/2/3', '0,5.2']) {
    test('incomplete or invalid numeric input $value is not submitted', () {
      final question = _question(
        kind: 'NUMERIC_INPUT',
        correct: {
          'values': ['0'],
        },
      );
      final answers = ExamAttemptAnswers()
        ..setNumericValue(0, question, value, practice: false);
      expect(answers.answeredCount, 0);
      expect(answers.submission(GeneratedExam(questions: [question])), isEmpty);
    });
  }

  test('numeric grading does not lose integer precision', () {
    final question = _question(
      kind: 'NUMERIC_INPUT',
      correct: {
        'values': ['9007199254740993'],
      },
    );
    expect(
      const ExamAnswerSelection(value: '9007199254740992').isCorrect(question),
      isFalse,
    );
    expect(
      const ExamAnswerSelection(value: '9007199254740993').isCorrect(question),
      isTrue,
    );
  });

  test(
    'question wire format has no old aliases and accepts image-only options',
    () {
      final dto = ExamQuestionDto.fromJson({
        'question_number': 1,
        'question_text': 'Pick a shape',
        'render_type': 'IDENTIFY_SHAPE',
        'question_image_url': 'https://example.com/stem',
        'options': [
          {
            'id': 'Shape-2',
            'text': '',
            'image_url': 'https://example.com/option',
          },
        ],
        'correct_answer': {
          'option_ids': ['Shape-2'],
        },
      });
      final json = dto.toJson();
      for (final old in [
        'question_name',
        'question_type',
        'answers',
        'right_answer_label',
        'right_answer_content',
      ]) {
        expect(json, isNot(contains(old)));
      }
      expect(json['correct_answer'], {
        'option_ids': ['Shape-2'],
      });
      expect(
        dto.toModel().options.single.imageUrl,
        'https://example.com/option',
      );
      expect(dto.toModel().options.single.text, isEmpty);
    },
  );

  test(
    'review keeps sitting order, exact IDs, summaries and server grading',
    () {
      final detail = ExamDetailAnswerDto.fromJson({
        'question_number': 7,
        'question_text': 'Select',
        'question_kind': 'MULTIPLE_CHOICE',
        'options': _options,
        'right_option_ids': ['c', 'Bank-B'],
        'child_option_ids': ['Bank-B', 'c'],
        'right_answer_text': '3 | 5',
        'child_answer_text': '5 | 3',
        'is_correct': true,
      });
      final question = detail.toQuestionModel(questionNumber: 7);
      final exam = GeneratedExam(
        questions: [question],
        answers: [detail.toSubmittedAnswer()!.toModel()],
      );
      expect(question.options.map((a) => a.id), ['Bank-B', 'bank-a', 'c']);
      expect(question.reviewCorrectText, '3 | 5');
      expect(examReviewComputedCorrectCount(exam), 1);
      final review = ReviewDetailController(
        detailId: 7,
        loadDetail: (_) async => exam,
        initialExam: exam,
      );
      addTearDown(review.dispose);
      review.selectAnswer(7, 'Bank-B');
      review.selectAnswer(7, 'c');
      expect(
        ExamAnswerSelection.fromState(
          question,
          review.retryAnswers[7]!,
        ).optionIds,
        ['Bank-B', 'c'],
      );
      review.selectAnswer(7, 'Bank-B');
      expect(
        ExamAnswerSelection.fromState(
          question,
          review.retryAnswers[7]!,
        ).optionIds,
        ['c'],
      );
    },
  );

  test('numeric review and skipped responses work without options', () {
    final detail = ExamDetailAnswerDto.fromJson({
      'question_number': 4,
      'question_kind': 'NUMERIC_INPUT',
      'right_option_ids': [],
      'child_option_ids': [],
      'right_answer_text': '0.5',
      'child_answer_text': '1/2',
      'is_correct': true,
    });
    final question = detail.toQuestionModel(questionNumber: 4);
    expect(question.options, isEmpty);
    expect(detail.toSubmittedAnswer()!.toJson(), {
      'question_number': 4,
      'value': '1/2',
    });
    expect(examReviewIsCorrect(question, '1/2'), isTrue);
    expect(
      ExamDetailAnswerDto.fromJson({
        'question_number': 1,
        'child_option_ids': [],
      }).toSubmittedAnswer(),
      isNull,
    );
  });

  test(
    'image refresh preserves answer keys and selections when detail hides them',
    () {
      final source = GeneratedExam(
        questions: [
          ExamQuestionDto.fromJson({
            'question_number': 1,
            'question_text': 'Pick',
            'options': _options,
            'correct_answer': {
              'option_ids': ['Bank-B'],
            },
            'question_image_url': 'old',
          }).toModel(),
        ],
        answers: const [
          SubmitExamAnswer(questionNumber: 1, optionIds: ['Bank-B']),
        ],
      );
      final fresh = GeneratedExam(
        questions: [
          ExamQuestionDto.fromJson({
            'question_number': 1,
            'question_text': 'Pick',
            'options': [
              {'id': 'Bank-B', 'text': '5', 'image_url': 'fresh-option'},
              {'id': 'bank-a', 'text': '4'},
              {'id': 'c', 'text': '3'},
            ],
            'question_image_url': 'fresh-stem',
          }).toModel(),
        ],
      );
      final updated = source.withRefreshedImages(fresh);
      expect(updated.questions.single.correctOptionIds, ['Bank-B']);
      expect(updated.questions.single.questionImageUrl, 'fresh-stem');
      expect(updated.questions.single.options.first.imageUrl, 'fresh-option');
      expect(updated.answers, same(source.answers));
    },
  );

  testWidgets('signed image URLs refresh during a long sitting', (
    tester,
  ) async {
    final question = _question();
    final source = GeneratedExam(
      examId: 1,
      questions: [
        ExamQuestion(
          questionNumber: question.questionNumber,
          questionText: question.questionText,
          options: question.options,
          questionImageUrl: 'old',
        ),
      ],
    );
    var current = source;
    var loads = 0;
    final refresher = ExamImageRefresher(
      load: (_) async {
        loads++;
        return GeneratedExam(
          questions: [
            ExamQuestion(
              questionNumber: question.questionNumber,
              questionText: question.questionText,
              options: question.options,
              questionImageUrl: 'new',
            ),
          ],
        );
      },
      isCurrent: (s) => identical(s, current),
      apply: (fresh) => current = fresh,
    );
    addTearDown(refresher.dispose);
    refresher.schedule(source);
    await tester.pump(const Duration(minutes: 51));
    expect(loads, 1);
    expect(current.questions.single.questionImageUrl, 'new');
    refresher.dispose();
  });

  test('grading failure offers generation of a new paper', () async {
    final question = _question(
      correct: {
        'option_ids': ['Bank-B'],
      },
    );
    final service = _Service(GeneratedExam(examId: 11, questions: [question]));
    final controller = ExamAttemptController(
      examService: service,
      initialExam: service.exam,
      examType: examTypeGrade,
    );
    addTearDown(controller.dispose);
    controller.selectAnswer(question.options.first);
    await controller.submitCurrentExam();
    expect(controller.needsNewPaper, isTrue);
    expect(controller.errorRetryAction, ExamAttemptRetryAction.generate);
    expect(await controller.retryGeneration(), isTrue);
    expect(service.generations, 1);
    expect(controller.selectedAnswerLabels, isEmpty);
  });

  test(
    'an empty old paper exposes recovery instead of an endless loader',
    () async {
      final service = _Service(
        GeneratedExam(examId: 12, questions: [_question()]),
      );
      final controller = ExamAttemptController(
        examService: service,
        initialExam: const GeneratedExam(examId: 1, questions: []),
      );
      addTearDown(controller.dispose);
      expect(controller.needsNewPaper, isTrue);
      expect(controller.isGeneratingQuestion, isFalse);
      expect(await controller.retryGeneration(), isTrue);
    },
  );

  test('numeric drafts enable continue only when valid', () {
    final question = _question(
      kind: 'NUMERIC_INPUT',
      correct: {
        'values': ['0.5'],
      },
    );
    final service = _Service(GeneratedExam(examId: 13, questions: [question]));
    final controller = ExamAttemptController(
      examService: service,
      initialExam: service.exam,
    );
    addTearDown(controller.dispose);
    controller.setNumericValue('1/');
    expect(controller.numericValue, '1/');
    expect(controller.canContinue, isFalse);
    expect(controller.selectedAnswerLabels, isEmpty);
    controller.setNumericValue('1/2');
    expect(controller.canContinue, isTrue);
    expect(controller.correctAnswerCount, 1);
    controller.setNumericValue('');
    expect(controller.canContinue, isFalse);
    expect(controller.allQuestionsAnswered, isFalse);
  });

  test(
    'practice multiple choice keeps the complete first set after continuing',
    () {
      final question = _question(
        kind: 'MULTIPLE_CHOICE',
        correct: {
          'option_ids': ['Bank-B', 'c'],
        },
      );
      final answers = ExamAttemptAnswers();
      answers.select(0, question, question.options.first, practice: true);
      answers.select(0, question, question.options.last, practice: true);
      answers.commitPractice(0);
      answers.select(0, question, question.options.last, practice: true);
      final exam = GeneratedExam(questions: [question]);
      expect(answers.submission(exam).single.selectedOptionIds, [
        'Bank-B',
        'c',
      ]);
      expect(answers.score(exam).correctCount, 1);
      expect(answers.selectedIsCorrect(question, 0, practice: true), isFalse);
    },
  );

  test('expired image URLs cannot be reused from the detail cache', () async {
    final stale = GeneratedExam(
      examId: 14,
      imageUrlsFetchedAt: DateTime.now().subtract(const Duration(hours: 1)),
      questions: const [
        ExamQuestion(
          questionNumber: 1,
          questionText: 'Image',
          questionImageUrl: 'expired',
          options: [],
        ),
      ],
    );
    ExamCache.seedDetail(stale);
    expect(ExamCache.peekDetail(14), isNull);
    var loads = 0;
    final refreshed = await ExamCache.loadDetail(
      cacheKey: 14,
      serviceExamId: 14,
      loadDetail: (_) async {
        loads++;
        return GeneratedExam(
          examId: 14,
          imageUrlsFetchedAt: DateTime.now(),
          questions: const [
            ExamQuestion(
              questionNumber: 1,
              questionText: 'Image',
              questionImageUrl: 'fresh',
              options: [],
            ),
          ],
        );
      },
    );
    expect(loads, 1);
    expect(refreshed.questions.single.questionImageUrl, 'fresh');
  });

  testWidgets('letters follow display order while selection uses stable IDs', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        home: Scaffold(
          body: AssessmentAnswerGrid(
            options: _question().options,
            selectedAnswerLabel: null,
            selectedOptionIds: const {'bank-a', 'c'},
            onSelected: (a) => selected = a.id,
          ),
        ),
      ),
    );
    final buttons = find.byType(AssessmentAnswerButton);
    expect(
      tester.widget<AssessmentAnswerButton>(buttons.first).displayLabel,
      'A',
    );
    expect(
      tester.widget<AssessmentAnswerButton>(buttons.at(1)).selected,
      isTrue,
    );
    expect(
      tester.widget<AssessmentAnswerButton>(buttons.at(2)).selected,
      isTrue,
    );
    await tester.tap(buttons.first);
    expect(selected, 'Bank-B');
  });

  testWidgets(
    'numeric retry accepts fractions and keeps drafts across rebuilds',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      var value = '';
      await tester.pumpWidget(
        MaterialApp(
          home: LingoScope(
            lingo: lingo,
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => ExamReviewAnswerList(
                  question: _question(kind: 'NUMERIC_INPUT'),
                  selectedLabel: value,
                  onSelected: (next) => setState(() => value = next),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '1/');
      await tester.pump();
      expect(value, '1/');
      await tester.enterText(find.byType(TextField), '1/2');
      await tester.pump();
      expect(value, '1/2');
      expect(find.byType(ExamNumericInput), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Service extends Fake implements ExamService {
  _Service(this.exam);
  final GeneratedExam exam;
  int generations = 0;

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    generations++;
    return exam;
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async => throw const ExamException('Old paper', status: 13713);
}
