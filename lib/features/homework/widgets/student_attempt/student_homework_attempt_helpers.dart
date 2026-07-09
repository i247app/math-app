import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';

class StudentHomeworkAttemptQuestion {
  const StudentHomeworkAttemptQuestion({
    required this.questionNumber,
    required this.prompt,
    required this.answers,
  });

  final int questionNumber;
  final String prompt;
  final List<StudentHomeworkAttemptAnswer> answers;

  String? selectedAnswerContent(String label) {
    for (final answer in answers) {
      if (answer.label == label) {
        return answer.content;
      }
    }
    return null;
  }
}

class StudentHomeworkAttemptAnswer {
  const StudentHomeworkAttemptAnswer({
    required this.label,
    required this.content,
  });

  final String label;
  final String content;
}

List<StudentHomeworkAttemptQuestion> studentHomeworkAttemptQuestions(
  ClassroomExercise? exercise,
) {
  final questions = exercise?.questions ?? const <ClassroomExerciseQuestion>[];
  return <StudentHomeworkAttemptQuestion>[
    for (var index = 0; index < questions.length; index++)
      StudentHomeworkAttemptQuestion(
        questionNumber: questions[index].questionNumber ?? index + 1,
        prompt: questions[index].displayPrompt ?? '',
        answers: <StudentHomeworkAttemptAnswer>[
          for (
            var answerIndex = 0;
            answerIndex < questions[index].answers.length;
            answerIndex++
          )
            if (questions[index].answers[answerIndex].trim().isNotEmpty)
              StudentHomeworkAttemptAnswer(
                label: _answerLabel(answerIndex),
                content: questions[index].answers[answerIndex].trim(),
              ),
        ],
      ),
  ];
}

String? studentHomeworkAttemptQuestionDataError(
  BuildContext context,
  List<StudentHomeworkAttemptQuestion> questions,
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
