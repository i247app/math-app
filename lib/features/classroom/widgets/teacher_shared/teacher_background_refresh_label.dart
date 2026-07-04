part of '../../presentation/teacher_classroom_screens.dart';

class TeacherBackgroundRefreshLabel extends StatelessWidget {
  const TeacherBackgroundRefreshLabel({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14 * scale),
      child: Text(
        context.getText(AppKeys.loading),
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: teacherMuted,
          fontSize: FontSize.caption * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
