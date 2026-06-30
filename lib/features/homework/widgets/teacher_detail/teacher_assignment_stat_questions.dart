part of '../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherAssignmentStatQuestions extends StatelessWidget {
  const _TeacherAssignmentStatQuestions(this.exercise);

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return _TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentQuestionCountLabel),
      iconAsset: 'assets/images/teacher_homework_detail_questions.svg',
      value: _teacherExerciseQuestionCount(context, exercise),
      valueFontSize: 16,
    );
  }
}
