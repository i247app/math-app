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

    test('clamps a two-grade normal upgrade at grade 5', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 4),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 5);
      expect(decision.nextState.mode, AssessmentFlowMode.normal);
    });

    test('normal downgrades after at least four wrong in the first five', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 3),
        _score(correctIndexes: const <int>{0}, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 2);
      expect(decision.nextState.mode, AssessmentFlowMode.recovery);
      expect(decision.nextState.isFailed, isTrue);
    });

    test(
      'four consecutive wrong answers fail immediately at question four',
      () {
        final decision = AssessmentFlowPolicy.decide(
          const AssessmentFlowState(grade: 3),
          _score(correct: 0, answered: 4),
        );

        expect(decision.action, AssessmentFlowAction.generateSet);
        expect(decision.nextState.grade, 2);
        expect(decision.nextState.mode, AssessmentFlowMode.recovery);
        expect(decision.nextState.isFailed, isTrue);
      },
    );

    test(
      'four consecutive wrong answers after question five do not fail early',
      () {
        final decision = AssessmentFlowPolicy.decide(
          const AssessmentFlowState(grade: 3),
          _score(correctIndexes: const <int>{0, 1, 2, 3, 4}, answered: 9),
        );

        expect(decision.action, AssessmentFlowAction.continueSet);
        expect(decision.nextState.grade, 3);
        expect(decision.nextState.isFailed, isFalse);
      },
    );

    test('normal early downgrade at grade zero submits five answers', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 0),
        _score(correct: 0, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 0);
      expect(decision.nextState.isFailed, isTrue);
    });

    test('three wrong in the first five still continues the set', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 3),
        _score(correctIndexes: const <int>{0, 1}, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.continueSet);
      expect(decision.nextState.grade, 3);
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

    test('normal pass without both Q3 and Q6 submits at the same grade', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 3),
        _score(correctIndexes: const <int>{0, 1, 3, 4, 6, 7}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 3);
      expect(decision.nextState.isFailed, isFalse);
    });

    test('normal special upgrade at grade 5 submits instead', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 5),
        _score(correctIndexes: const <int>{0, 2, 4, 5, 8}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 5);
    });

    test('normal fail at grade zero marks failed and submits', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(grade: 0),
        _score(correct: 4, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 0);
      expect(decision.nextState.isFailed, isTrue);
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

    test('recovery downgrades early into downgrade mode', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correctIndexes: const <int>{0}, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 1);
      expect(decision.nextState.mode, AssessmentFlowMode.downgrade);
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

    test('recovery special upgrade at grade 5 submits instead', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 5,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correctIndexes: const <int>{0, 2, 4, 5, 8}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 5);
      expect(decision.nextState.isFailed, isTrue);
    });

    test('recovery fail steps down into downgrade mode', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correct: 4, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 1);
      expect(decision.nextState.mode, AssessmentFlowMode.downgrade);
      expect(decision.nextState.isFailed, isTrue);
    });

    test('recovery fail at grade zero submits', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 0,
          mode: AssessmentFlowMode.recovery,
          isFailed: true,
          setNumber: 2,
        ),
        _score(correct: 4, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 0);
    });

    test('verification never ends early after six correct answers', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 3,
          mode: AssessmentFlowMode.verification,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.continueSet);
    });

    test('verification pass submits at the verified grade', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 3,
          mode: AssessmentFlowMode.verification,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correctIndexes: const <int>{0, 1, 3, 4, 6, 7}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 3);
    });

    test('verification downgrades and submits after four early misses', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 3,
          mode: AssessmentFlowMode.verification,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correctIndexes: const <int>{0}, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 2);
    });

    test('verification fail submits one grade lower', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 3,
          mode: AssessmentFlowMode.verification,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correctIndexes: const <int>{0, 2, 4, 5, 8}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 2);
    });

    test('verification fail never lowers grade below zero', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 0,
          mode: AssessmentFlowMode.verification,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correct: 4, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 0);
    });

    test('downgrade mode never ends early after six correct answers', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.downgrade,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correct: 6),
      );

      expect(decision.action, AssessmentFlowAction.continueSet);
    });

    test('downgrade pass submits at the current grade', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.downgrade,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correctIndexes: const <int>{0, 1, 3, 4, 6, 7}, answered: 10),
      );

      expect(decision.action, AssessmentFlowAction.submit);
      expect(decision.nextState.grade, 2);
    });

    test('downgrade mode steps down after four early misses', () {
      final decision = AssessmentFlowPolicy.decide(
        const AssessmentFlowState(
          grade: 2,
          mode: AssessmentFlowMode.downgrade,
          isFailed: true,
          setNumber: 3,
        ),
        _score(correctIndexes: const <int>{0}, answered: 5),
      );

      expect(decision.action, AssessmentFlowAction.generateSet);
      expect(decision.nextState.grade, 1);
      expect(decision.nextState.mode, AssessmentFlowMode.downgrade);
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
