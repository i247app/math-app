part of '../../presentation/teacher_homework_screen.dart';

class _TeacherAssignmentStatDue extends StatelessWidget {
  const _TeacherAssignmentStatDue(this.exercise);

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return _TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentDueLabel),
      iconAsset: 'assets/images/teacher_homework_detail_calendar.svg',
      value: teacherExerciseDueDate(context, exercise),
      valueFontSize: 13,
    );
  }
}
