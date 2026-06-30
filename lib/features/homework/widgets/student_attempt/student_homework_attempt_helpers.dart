part of '../../presentation/student_homework_attempt_screen.dart';

class _StudentHomeworkAttemptQuestion {
  const _StudentHomeworkAttemptQuestion({
    required this.questionNumber,
    required this.prompt,
    required this.answers,
  });

  final int questionNumber;
  final String prompt;
  final List<_StudentHomeworkAttemptAnswer> answers;

  String? selectedAnswerContent(String label) {
    for (final answer in answers) {
      if (answer.label == label) {
        return answer.content;
      }
    }
    return null;
  }
}

class _StudentHomeworkAttemptAnswer {
  const _StudentHomeworkAttemptAnswer({
    required this.label,
    required this.content,
  });

  final String label;
  final String content;
}

List<_StudentHomeworkAttemptQuestion> _attemptQuestions(
  ClassroomExercise? exercise,
) {
  final questions = exercise?.questions ?? const <ClassroomExerciseQuestion>[];
  return <_StudentHomeworkAttemptQuestion>[
    for (var index = 0; index < questions.length; index++)
      _StudentHomeworkAttemptQuestion(
        questionNumber: questions[index].questionNumber ?? index + 1,
        prompt: questions[index].displayPrompt ?? '',
        answers: <_StudentHomeworkAttemptAnswer>[
          for (
            var answerIndex = 0;
            answerIndex < questions[index].answers.length;
            answerIndex++
          )
            if (questions[index].answers[answerIndex].trim().isNotEmpty)
              _StudentHomeworkAttemptAnswer(
                label: _answerLabel(answerIndex),
                content: questions[index].answers[answerIndex].trim(),
              ),
        ],
      ),
  ];
}

String? _questionDataError(
  BuildContext context,
  List<_StudentHomeworkAttemptQuestion> questions,
) {
  if (questions.isEmpty) {
    return context.getText(AppKeys.studentHomeworkNoQuestions);
  }
  if (questions.any((question) => question.answers.isEmpty)) {
    return context.getText(AppKeys.studentHomeworkQuestionMissingAnswers);
  }
  return null;
}

String _answerLabel(int index) {
  if (index >= 0 && index < 26) {
    return String.fromCharCode(65 + index);
  }
  return (index + 1).toString();
}
