import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';

void main() {
  group('AssessmentFlowPolicy', () {
    test('upgrades two grades after the first six correct answers', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 0),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 2);
      expect(decision.nextState.setNumber, 2);
      expect(decision.nextState.mode, AssessmentFlowMode.normal);
    });

    test('submits instead of generating above grade 5', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 5),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 5);
    });

    test('50 percent without both Q3 and Q6 enters recovery', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 3),
        _score(correct: 5, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 2);
      expect(decision.nextState.mode, AssessmentFlowMode.recovery);
      expect(decision.nextState.isFailed, isTrue);
    });

    test('50 percent with Q3 and Q6 correct upgrades one grade', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 2),
        _score(correctIndexes: const <int>{0, 2, 4, 5, 8}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 3);
      expect(decision.nextState.mode, AssessmentFlowMode.normal);
      expect(decision.nextState.isFailed, isFalse);
    });

    test('recovery also upgrades at 50 percent when Q3 and Q6 are correct', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correctIndexes: const <int>{0, 2, 4, 5, 8}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 3);
      expect(decision.nextState.mode, AssessmentFlowMode.verification);
      expect(decision.nextState.isFailed, isTrue);
    });

    test('recovery pass without an upgrade condition submits', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correctIndexes: const <int>{1, 3, 4, 6, 7, 8}, answered: 10),
      );

      // Q1, Q3, Q6 and one more answer are wrong, leaving 6/10 correct.
      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 2);
    });

    test('recovery excellence upgrades one grade then verifies', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 3);
      expect(decision.nextState.mode, AssessmentFlowMode.verification);
    });

    test('downgrade mode keeps stepping down until grade zero', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 1,
          mode: AssessmentFlowMode.downgrade,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correct: 4, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 0);
      expect(decision.nextState.mode, AssessmentFlowMode.downgrade);

      final gradeZeroDecision = AssessmentFlowPolicy.decide(
        decision.nextState,
        _score(correct: 4, answered: 10),
      );
      expect(gradeZeroDecision.action, AssessmentFlowAction.submit);
      expect(gradeZeroDecision.nextState.grade, 0);
    });
  });
}

AssessmentSetScore _score({
  int? correct,
  Set<int>? correctIndexes,
  int? answered,
}) {
  final indexes =
      correctIndexes ??
      <int>{for (var index = 0; index < (correct ?? 0); index++) index};
  return AssessmentSetScore(
    totalQuestions: 10,
    answeredQuestionIndexes: <int>{
      for (var index = 0; index < (answered ?? indexes.length); index++) index,
    },
    correctQuestionIndexes: indexes,
  );
}
