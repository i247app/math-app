import 'package:numi/features/exam/data/profile_grade_progress_store.dart';
import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/helpers/grade_exam_flow_policy.dart';
import 'package:numi/features/exam/helpers/practice_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_attempt_answers.dart';
import 'package:numi/features/exam/models/exam_attempt_state.dart';

/// Applies each mode's policy and records committed assessment set transitions.
/// It does not perform requests or publish UI loading/error state.
class ExamAttemptFlow {
  ExamAttemptFlow({
    required ExamAttemptKind kind,
    GeneratedExam? initialExam,
    String? gradeLabel,
    int? level,
  }) {
    _state = AssessmentFlowState(
      grade: AssessmentFlowPolicy.clampGrade(
        initialExam?.grade ??
            AssessmentFlowPolicy.gradeFromLabel(
              gradeLabel,
              fallback: kind == ExamAttemptKind.assessment ? 0 : 1,
            ),
      ),
    );
    _currentLevel = _level(initialExam?.level ?? level ?? 1, kind);
    _questionNumberOffset = initialExam?.questionNumberOffset ?? 0;
  }

  late AssessmentFlowState _state;
  late int _currentLevel;
  late int _questionNumberOffset;
  bool _allowsPartialSubmit = false;
  AssessmentFlowDecision? _pendingDecision;
  AssessmentFlowState get state => _state;
  int get currentLevel => _currentLevel;
  int get questionNumberOffset => _questionNumberOffset;
  bool get allowsPartialSubmit => _allowsPartialSubmit;
  AssessmentFlowDecision? get pendingDecision => _pendingDecision;

  void selectionChanged() => _allowsPartialSubmit = false;

  final List<AssessmentSetRecord> _completedSets = [];
  List<AssessmentSetRecord> get completedSets =>
      List.unmodifiable(_completedSets);

  void reset({
    required int grade,
    required int level,
    required ExamAttemptKind kind,
  }) {
    _state = AssessmentFlowState(grade: grade);
    _currentLevel = _level(level, kind);
    _questionNumberOffset = 0;
    _allowsPartialSubmit = false;
    _completedSets.clear();
    _pendingDecision = null;
  }

  void restoreGenerated(GeneratedExam exam, ExamAttemptKind kind) {
    _questionNumberOffset = exam.questionNumberOffset;
    if (kind == ExamAttemptKind.assessment && exam.questionNumberOffset > 0) {
      _state = _state.copyWith(
        grade: AssessmentFlowPolicy.clampGrade(exam.grade ?? _state.grade),
      );
    }
  }

  AssessmentFlowDecision assessmentDecision(AssessmentSetScore score) =>
      AssessmentFlowPolicy.decide(_state, score);

  AssessmentFlowAction prepareSubmit(
    ExamAttemptKind kind,
    AssessmentSetScore score,
  ) {
    if (kind == ExamAttemptKind.assessment) {
      final decision = assessmentDecision(score);
      if (decision.action != AssessmentFlowAction.submit) {
        return AssessmentFlowAction.continueSet;
      }
      _state = decision.nextState;
    } else {
      final submit = switch (kind) {
        ExamAttemptKind.grade => shouldSubmitGrade(score),
        ExamAttemptKind.practice => PracticeFlowPolicy.shouldSubmit(
          PracticeSetScore(
            totalQuestions: score.totalQuestions,
            answeredQuestionIndexes: score.answeredQuestionIndexes,
            correctQuestionIndexes: score.correctQuestionIndexes,
          ),
        ),
        _ => false,
      };
      if (!submit) return AssessmentFlowAction.continueSet;
    }
    _allowsPartialSubmit = !score.isComplete;
    return AssessmentFlowAction.submit;
  }

  bool shouldSubmitGrade(AssessmentSetScore score) =>
      GradeExamFlowPolicy.shouldSubmit(score);

  GradeExamOutcome gradeOutcome(
    AssessmentSetScore score,
    ProfileGradeProgress savedProgress,
  ) => GradeExamFlowPolicy.evaluate(
    attemptedGrade: _state.grade,
    attemptedLevel: _currentLevel,
    score: score,
    savedProgress: savedProgress,
  );

  void applySubmit(AssessmentFlowDecision decision, AssessmentSetScore score) {
    _state = decision.nextState;
    _allowsPartialSubmit = !score.isComplete;
  }

  void beginTransition(AssessmentFlowDecision decision) {
    _pendingDecision = decision;
    if (decision.nextState.isFailed && !_state.isFailed) {
      _state = _state.copyWith(isFailed: true);
    }
  }

  void commitTransition(
    GeneratedExam source,
    ExamAttemptAnswers answers,
    AssessmentFlowDecision decision,
  ) {
    _completedSets.add(
      AssessmentSetRecord(
        exam: source,
        grade: _state.grade,
        mode: _state.mode,
        setNumber: _state.setNumber,
        selectedAnswerLabels: answers.firstAttempts,
        correctAnswerCount: answers.score(source).correctCount,
      ),
    );
    _questionNumberOffset += answers.answeredCount;
    _state = decision.nextState;
    _pendingDecision = null;
    _allowsPartialSubmit = false;
  }

  int _level(int level, ExamAttemptKind kind) => level.clamp(
    kind == ExamAttemptKind.grade ? GradeExamFlowPolicy.minimumLevel : 1,
    GradeExamFlowPolicy.maximumLevel,
  );
}
