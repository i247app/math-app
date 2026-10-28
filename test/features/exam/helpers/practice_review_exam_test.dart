import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/helpers/practice_review_exam.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_attempt_answers.dart';

void main() {
  const wrong = ExamAnswer(id: 'A', text: '18');
  const correct = ExamAnswer(id: 'B', text: '20');
  const source = GeneratedExam(
    examId: 7,
    profileId: 12,
    examType: examTypePractice,
    userExamId: 70,
    grade: 3,
    level: 2,
    title: 'Original',
    shortText: 'Original description',
    practiceWeakTopics: [
      ExamPracticeTopic(topic: 'Addition', answered: 4, wrong: 2),
    ],
    questions: [
      ExamQuestion(
        questionNumber: 10,
        questionText: 'Q10',
        options: [wrong, correct],
        correctOptionIds: ['B'],
      ),
      ExamQuestion(
        questionNumber: 20,
        questionText: 'Q20',
        options: [wrong, correct],
        correctOptionIds: ['B'],
      ),
      ExamQuestion(
        questionNumber: 30,
        questionText: 'Q30',
        options: [wrong, correct],
      ),
    ],
  );

  test('Practice retries change feedback while submission and score keep first attempts', () {
    final answers = ExamAttemptAnswers();
    final question = source.questions.first;
    answers.select(0, question, wrong, practice: true);
    expect(answers.feedbackAt(0), isFalse);
    answers.select(0, question, correct, practice: true);
    expect(answers.feedbackAt(0), isTrue);
    expect(answers.selectedLabel(0, practice: true), 'B');
    expect(answers.firstAttempts, {0: 'A'});
    expect(answers.score(source).correctCount, 0);
    expect(answers.submission(source).single.questionNumber, 10);
    expect(answers.submission(source).single.selectedOptionIds.single, 'A');
    expect(answers.clearFeedback(0), isTrue);
    expect(answers.feedbackAt(0), isNull);
    expect(answers.clearFeedback(0), isFalse);
    expect(() => answers.firstAttempts[0] = 'B', throwsUnsupportedError);
  });

  test('resumed answers map question numbers to indexes and clamp the resume position', () {
    final answers = ExamAttemptAnswers();
    final index = answers.restore(
      GeneratedExam(
        questions: source.questions,
        resumeQuestionIndex: 99,
        answers: const [
          SubmitExamAnswer(questionNumber: 20, optionIds: ['B']),
          SubmitExamAnswer(questionNumber: 999, optionIds: ['A']),
          SubmitExamAnswer(questionNumber: 10, optionIds: [' ']),
        ],
      ),
    );
    expect(index, 2);
    expect(answers.firstAttempts, {1: 'B'});
    expect(answers.firstUnansweredIndex(source.questions), 0);
    expect(answers.score(source).correctCount, 1);
    expect(
      ExamAttemptAnswers.isAnswerCorrect(source.questions.last, correct),
      isNull,
    );
  });

  test('Practice review preserves generated context and recomputes partial grading', () {
    const response = GeneratedExam(
      examId: 7,
      userExamId: 99,
      grade: 5,
      level: 4,
      title: 'Submitted',
      aiReviewLong: 'Server review',
      grading: ExamGrading(
        totalQuestions: 10,
        correctNumber: 10,
        skippedNumber: 8,
        scorePercentage: 100,
      ),
      questions: [],
    );
    final answers = [
      const SubmitExamAnswer(questionNumber: 10, optionIds: ['A']),
      const SubmitExamAnswer(questionNumber: 20, optionIds: ['B']),
    ];
    final review = buildPracticeReviewExam(
      sourceExam: source,
      submittedExam: response,
      answers: answers,
    );
    expect(review.questions, same(source.questions));
    expect(review.examType, examTypePractice);
    expect(review.grade, 3);
    expect(review.level, 4);
    expect(review.userExamId, 70);
    expect(review.profileId, 12);
    expect(review.title, 'Submitted');
    expect(review.shortText, 'Original description');
    expect(review.aiReviewLong, 'Server review');
    expect(review.practiceWeakTopics, same(source.practiceWeakTopics));
    expect(review.grading!.totalQuestions, 2);
    expect(review.grading!.correctNumber, 1);
    expect(review.grading!.scorePercentage, 50);
    expect(review.grading!.skippedNumber, 0);
    answers.clear();
    expect(review.answers, hasLength(2));
    expect(() => review.answers.clear(), throwsUnsupportedError);
  });

  test(
    'empty Practice submission yields zero grading instead of dividing by zero',
    () {
      final review = buildPracticeReviewExam(
        sourceExam: source,
        submittedExam: const GeneratedExam(questions: []),
        answers: [],
      );
      expect(review.grading!.scorePercentage, 0);
      expect(review.grading!.totalQuestions, 0);
      expect(review.grading!.correctNumber, 0);
    },
  );
}
