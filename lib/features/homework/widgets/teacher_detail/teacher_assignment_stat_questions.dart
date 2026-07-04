part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAssignmentStatQuestions extends StatelessWidget {
  const _TeacherAssignmentStatQuestions(this.exercise);

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return _TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentQuestionCountLabel),
      iconAsset: 'assets/images/teacher_homework_detail_questions.svg',
      value: teacherExerciseQuestionCount(context, exercise),
      valueFontSize: 16,
    );
  }
}
