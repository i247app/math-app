import 'package:numi/features/exam/helpers/assessment_flow_policy.dart';
import 'package:numi/features/exam/models/exam.dart';

/// Owns first attempts, Practice retries and feedback for one question set.
class ExamAttemptAnswers {
  final Map<int, String> _first = {};
  final Map<int, String> _practiceSelections = {};
  final Map<int, bool?> _feedback = {};

  Map<int, String> get firstAttempts => Map.unmodifiable(_first);
  int get answeredCount => _first.length;

  void clear() {
    _first.clear();
    _practiceSelections.clear();
    _feedback.clear();
  }

  int restore(GeneratedExam? exam) {
    final questions = exam?.questions ?? const <ExamQuestion>[];
    for (final answer in exam?.answers ?? const <SubmitExamAnswer>[]) {
      final label = answer.label.trim();
      if (label.isEmpty) continue;
      final index = questions.indexWhere(
        (question) => question.questionNumber == answer.questionNumber,
      );
      if (index >= 0) _first[index] = label;
    }
    if (questions.isEmpty) return 0;
    final resume = exam?.resumeQuestionIndex;
    return resume?.clamp(0, questions.length - 1) ??
        firstUnansweredIndex(questions) ??
        questions.length - 1;
  }

  String? selectedLabel(int index, {required bool practice}) =>
      practice ? _practiceSelections[index] : _first[index];
  bool? feedbackAt(int index) => _feedback[index];

  bool select(
    int index,
    ExamQuestion? question,
    ExamAnswer answer, {
    required bool practice,
  }) {
    if (practice) {
      _first.putIfAbsent(index, () => answer.label);
      _practiceSelections[index] = answer.label;
      _feedback[index] = question == null
          ? null
          : isAnswerCorrect(question, answer);
      return true;
    }
    if (_first[index] == answer.label) return false;
    _first[index] = answer.label;
    return true;
  }

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
  }) {
    final label = selectedLabel(index, practice: practice);
    if (question == null || label == null) return null;
    for (final answer in question.answers) {
      if (_normalized(answer.label) == _normalized(label)) {
        return isAnswerCorrect(question, answer);
      }
    }
    return null;
  }

  AssessmentSetScore score(GeneratedExam? exam) {
    final questions = exam?.questions ?? const <ExamQuestion>[];
    final correct = <int>{};
    for (final entry in _first.entries) {
      if (entry.key < 0 || entry.key >= questions.length) continue;
      final question = questions[entry.key];
      if (question.answers.any(
        (answer) =>
            _normalized(answer.label) == _normalized(entry.value) &&
            isAnswerCorrect(question, answer) == true,
      )) {
        correct.add(entry.key);
      }
    }
    return AssessmentSetScore(
      totalQuestions: questions.length,
      answeredQuestionIndexes: _first.keys.toSet(),
      correctQuestionIndexes: correct,
    );
  }

  List<SubmitExamAnswer> submission(GeneratedExam exam) => [
    for (var index = 0; index < exam.questions.length; index++)
      if (_first[index] case final label?)
        SubmitExamAnswer(
          questionNumber: exam.questions[index].questionNumber,
          label: label,
        ),
  ];

  static bool? isAnswerCorrect(ExamQuestion question, ExamAnswer answer) {
    final correct = <String?>[
      question.rightAnswer,
      question.correctAnswer,
    ].map(_normalized).whereType<String>().toSet();
    if (correct.isEmpty) return null;
    return correct.contains(_normalized(answer.label)) ||
        correct.contains(_normalized(answer.content));
  }

  static int correctSubmittedCount(
    GeneratedExam exam,
    List<SubmitExamAnswer> answers,
  ) {
    var count = 0;
    for (final submitted in answers) {
      final question = exam.questions
          .where(
            (question) => question.questionNumber == submitted.questionNumber,
          )
          .firstOrNull;
      if (question == null) continue;
      final answer = question.answers
          .where(
            (answer) =>
                _normalized(answer.label) == _normalized(submitted.label),
          )
          .firstOrNull;
      if (answer != null && isAnswerCorrect(question, answer) == true) count++;
    }
    return count;
  }

  static String? _normalized(String? value) {
    final normalized = value?.trim().toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
