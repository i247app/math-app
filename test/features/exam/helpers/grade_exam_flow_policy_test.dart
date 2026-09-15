import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';

void main() {
  AssessmentSetScore score(Set<int> correct) => AssessmentSetScore(
    totalQuestions: 10,
    answeredQuestionIndexes: Set<int>.from(List<int>.generate(10, (i) => i)),
    correctQuestionIndexes: correct,
  );

  test('first six correct advances two levels', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 5,
      attemptedLevel: 1,
      score: score({0, 1, 2, 3, 4, 5}),
      savedProgress: ProfileGradeProgress.initial,
    );

    expect(outcome.passed, isTrue);
    expect(outcome.levelIncrease, 2);
    expect(outcome.progress.grade, 5);
    expect(outcome.progress.level, 3);
  });

  test('first six correct advances before the remaining questions', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 1,
      attemptedLevel: 2,
      score: AssessmentSetScore(
        totalQuestions: 10,
        answeredQuestionIndexes: {0, 1, 2, 3, 4, 5},
        correctQuestionIndexes: {0, 1, 2, 3, 4, 5},
      ),
      savedProgress: const ProfileGradeProgress(grade: 1, level: 2),
    );

    expect(outcome.passed, isTrue);
    expect(outcome.levelIncrease, 2);
    expect(outcome.progress.grade, 1);
    expect(outcome.progress.level, 4);
  });

  test('at least fifty percent with question 3 advances one level', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 2,
      attemptedLevel: 4,
      score: score({0, 1, 2, 3, 6}),
      savedProgress: const ProfileGradeProgress(grade: 2, level: 4),
    );

    expect(outcome.levelIncrease, 1);
    expect(outcome.progress, isA<ProfileGradeProgress>());
    expect(outcome.progress.grade, 2);
    expect(outcome.progress.level, 5);
  });

  test('level overflow advances to the next grade', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 3,
      attemptedLevel: 10,
      score: score({0, 1, 2, 3, 4, 5}),
      savedProgress: const ProfileGradeProgress(grade: 3, level: 10),
    );

    expect(outcome.progress.grade, 4);
    expect(outcome.progress.level, 2);
  });

  test('failure keeps the higher saved profile progress', () {
    const saved = ProfileGradeProgress(grade: 2, level: 8);
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 5,
      attemptedLevel: 1,
      score: score({5, 6, 7, 8}),
      savedProgress: saved,
    );

    expect(outcome.passed, isFalse);
    expect(outcome.progress.grade, saved.grade);
    expect(outcome.progress.level, saved.level);
  });

  test('failure on the current grade drops one level', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 2,
      attemptedLevel: 6,
      score: score({0, 1, 6, 7}),
      savedProgress: const ProfileGradeProgress(grade: 2, level: 6),
    );

    expect(outcome.passed, isFalse);
    expect(outcome.levelIncrease, -1);
    expect(outcome.progress.grade, 2);
    expect(outcome.progress.level, 5);
  });

  test('failure at level one stays at level one', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 3,
      attemptedLevel: 1,
      score: score({0, 1, 6, 7}),
      savedProgress: const ProfileGradeProgress(grade: 3, level: 1),
    );

    expect(outcome.progress.grade, 3);
    expect(outcome.progress.level, 1);
  });

  test('pass without anchor keeps the attempted level', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 4,
      attemptedLevel: 6,
      score: score({0, 1, 3, 4, 6, 7, 8, 9}),
      savedProgress: const ProfileGradeProgress(grade: 2, level: 9),
    );

    expect(outcome.passed, isTrue);
    expect(outcome.levelIncrease, 0);
    expect(outcome.progress.grade, 4);
    expect(outcome.progress.level, 6);
  });

  test('five wrong first answers always fails the single set', () {
    final outcome = GradeExamFlowPolicy.evaluate(
      attemptedGrade: 1,
      attemptedLevel: 3,
      score: score({5, 6, 7, 8, 9}),
      savedProgress: const ProfileGradeProgress(grade: 1, level: 2),
    );

    expect(outcome.passed, isFalse);
    expect(outcome.levelIncrease, -1);
    expect(outcome.progress.level, 2);
  });
}
