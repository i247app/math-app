part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomHeader extends StatelessWidget {
  const _TeacherClassroomHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: context.getText(AppKeys.studentClassroom),
      scale: scale,
      actionWidth: 40,
      horizontalPadding: 18,
      verticalPadding: 6,
    );
  }
}
