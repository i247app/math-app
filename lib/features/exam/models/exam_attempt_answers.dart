import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/models/exam_answer_selection.dart';

/// Owns first attempts, Practice retries and feedback for one question set.
class ExamAttemptAnswers {
  final Map<int, ExamAnswerSelection> _first = {};
  final Map<int, ExamAnswerSelection> _drafts = {};
  final Map<int, ExamAnswerSelection> _practiceSelections = {};
  final Set<int> _practiceCommitted = {};
  final Map<int, bool?> _feedback = {};

  Map<int, String> get firstAttempts => Map.unmodifiable({
    for (final entry in _first.entries) entry.key: entry.value.stateValue,
  });
  int get answeredCount => _first.length;

  void clear() {
    _first.clear();
    _drafts.clear();
    _practiceSelections.clear();
    _practiceCommitted.clear();
    _feedback.clear();
  }

  int restore(GeneratedExam? exam) {
    final questions = exam?.questions ?? const <ExamQuestion>[];
    for (final answer in exam?.answers ?? const <SubmitExamAnswer>[]) {
      final index = questions.indexWhere(
        (q) => q.questionNumber == answer.questionNumber,
      );
      if (index < 0) continue;
      final question = questions[index];
      final selection = ExamAnswerSelection.fromSubmitted(question, answer);
      if (!selection.isValid) continue;
      if (!question.isNumericInput &&
          (selection.optionIds.any(
                (id) => !question.options.any((a) => a.id == id),
              ) ||
              (!question.isMultipleChoice &&
                  selection.optionIds.length != 1))) {
        continue;
      }
      _first[index] = selection;
      _practiceSelections[index] = selection;
    }
    if (questions.isEmpty) return 0;
    return exam?.resumeQuestionIndex?.clamp(0, questions.length - 1) ??
        firstUnansweredIndex(questions) ??
        questions.length - 1;
  }

  ExamAnswerSelection? selected(int index, {required bool practice}) =>
      practice ? _practiceSelections[index] : _drafts[index] ?? _first[index];
  String? selectedLabel(int index, {required bool practice}) =>
      selected(index, practice: practice)?.stateValue;
  bool? feedbackAt(int index) => _feedback[index];

  bool select(
    int index,
    ExamQuestion? question,
    ExamAnswer answer, {
    required bool practice,
  }) {
    if (question == null ||
        question.isNumericInput ||
        !question.options.any((a) => a.id == answer.id)) {
      return false;
    }
    final previous = selected(index, practice: practice);
    final ids = question.isMultipleChoice
        ? [...?previous?.optionIds]
        : <String>[];
    if (question.isMultipleChoice && ids.contains(answer.id)) {
      ids.remove(answer.id);
    } else {
      ids.add(answer.id);
    }
    final selection = ExamAnswerSelection(
      optionIds: List.unmodifiable(ids),
      multiple: question.isMultipleChoice,
    );
    if (!practice && previous?.stateValue == selection.stateValue) return false;
    _record(index, question, selection, practice: practice);
    return true;
  }

  void setNumericValue(
    int index,
    ExamQuestion question,
    String value, {
    required bool practice,
  }) {
    if (!question.isNumericInput) return;
    _record(
      index,
      question,
      ExamAnswerSelection(value: value),
      practice: practice,
    );
  }

  void _record(
    int index,
    ExamQuestion question,
    ExamAnswerSelection selection, {
    required bool practice,
  }) {
    _drafts[index] = selection;
    if (practice) {
      _practiceSelections[index] = selection;
      if (question.isMultipleChoice || question.isNumericInput) {
        if (!_practiceCommitted.contains(index)) {
          if (selection.isValid) {
            _first[index] = selection;
          } else {
            _first.remove(index);
          }
        }
        _feedback.remove(index);
      } else {
        _first.putIfAbsent(index, () => selection);
        _feedback[index] = selection.isCorrect(question);
      }
    } else if (selection.isValid) {
      _first[index] = selection;
    } else {
      _first.remove(index);
    }
  }

  void commitPractice(int index) => _practiceCommitted.add(index);

  bool clearFeedback(int index) {
    if (!_feedback.containsKey(index)) return false;
    _feedback.remove(index);
    return true;
  }

  int? firstUnansweredIndex(List<ExamQuestion> questions) {
    for (var index = 0; index < questions.length; index++) {
      if (_first[index] == null) return index;
    }
    return null;
  }

  bool? selectedIsCorrect(
    ExamQuestion? question,
    int index, {
    required bool practice,
  }) => question == null
      ? null
      : selected(index, practice: practice)?.isCorrect(question);

  AssessmentSetScore score(GeneratedExam? exam) {
    final questions = exam?.questions ?? const <ExamQuestion>[];
    return AssessmentSetScore(
      totalQuestions: questions.length,
      answeredQuestionIndexes: _first.keys.toSet(),
      correctQuestionIndexes: {
        for (final entry in _first.entries)
          if (entry.key >= 0 &&
              entry.key < questions.length &&
              entry.value.isCorrect(questions[entry.key]) == true)
            entry.key,
      },
    );
  }

  List<SubmitExamAnswer> submission(GeneratedExam exam) => [
    for (var index = 0; index < exam.questions.length; index++)
      if (_first[index] case final selection?)
        selection.submission(exam.questions[index].questionNumber),
  ];

  static bool? isAnswerCorrect(ExamQuestion question, ExamAnswer answer) =>
      ExamAnswerSelection(optionIds: [answer.id]).isCorrect(question);

  static int correctSubmittedCount(
    GeneratedExam exam,
    List<SubmitExamAnswer> answers,
  ) => answers.where((submitted) {
    final question = exam.questions
        .where((q) => q.questionNumber == submitted.questionNumber)
        .firstOrNull;
    return question != null &&
        ExamAnswerSelection.fromSubmitted(
              question,
              submitted,
            ).isCorrect(question) ==
            true;
  }).length;
}
