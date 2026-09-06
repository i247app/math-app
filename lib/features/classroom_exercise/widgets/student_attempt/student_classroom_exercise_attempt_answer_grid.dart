import 'package:flutter/material.dart';

import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_answer_button.dart';
import 'package:numi/features/classroom_exercise/widgets/student_attempt/student_classroom_exercise_attempt_helpers.dart';

class StudentClassroomExerciseAttemptAnswerGrid extends StatelessWidget {
  const StudentClassroomExerciseAttemptAnswerGrid({
    super.key,
    required this.answers,
    required this.selectedAnswerLabel,
    required this.onSelected,
  });
  final List<StudentClassroomExerciseAttemptAnswer> answers;
  final String? selectedAnswerLabel;
  final ValueChanged<StudentClassroomExerciseAttemptAnswer> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: answers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 96,
      ),
      itemBuilder: (context, index) {
        final answer = answers[index];
        return StudentClassroomExerciseAttemptAnswerButton(
          answer: answer,
          selected: answer.label == selectedAnswerLabel,
          onTap: () => onSelected(answer),
        );
      },
    );
  }
}
