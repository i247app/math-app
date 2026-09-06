import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';

class StudentClassroomExerciseAttemptQuestion {
  const StudentClassroomExerciseAttemptQuestion({
    required this.questionNumber,
    required this.prompt,
    required this.answers,
  });

  final int questionNumber;
  final String prompt;
  final List<StudentClassroomExerciseAttemptAnswer> answers;

  String? selectedAnswerContent(String label) {
    for (final answer in answers) {
      if (answer.label == label) {
        return answer.content;
      }
    }
    return null;
  }
}

class StudentClassroomExerciseAttemptAnswer {
  const StudentClassroomExerciseAttemptAnswer({
    required this.label,
    required this.content,
  });

  final String label;
  final String content;
}

List<StudentClassroomExerciseAttemptQuestion>
studentClassroomExerciseAttemptQuestions(ClassroomExercise? exercise) {
  final questions = exercise?.questions ?? const <ClassroomExerciseQuestion>[];
  return <StudentClassroomExerciseAttemptQuestion>[
    for (var index = 0; index < questions.length; index++)
      StudentClassroomExerciseAttemptQuestion(
        questionNumber: questions[index].questionNumber ?? index + 1,
        prompt: questions[index].displayPrompt ?? '',
        answers: <StudentClassroomExerciseAttemptAnswer>[
          for (
            var answerIndex = 0;
            answerIndex < questions[index].answers.length;
            answerIndex++
          )
            if (questions[index].answers[answerIndex].trim().isNotEmpty)
              StudentClassroomExerciseAttemptAnswer(
                label: _answerLabel(answerIndex),
                content: questions[index].answers[answerIndex].trim(),
              ),
        ],
      ),
  ];
}

String _answerLabel(int index) {
  if (index >= 0 && index < 26) {
    return String.fromCharCode(65 + index);
  }
  return (index + 1).toString();
}
