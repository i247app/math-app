part of '../../presentation/teacher_classroom_screens.dart';

class _TeacherClassroomEmptyState extends StatelessWidget {
  const _TeacherClassroomEmptyState({
    required this.scale,
    required this.message,
  });

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            color: _teacherMuted,
            fontSize: FontSize.normal * scale,
          ),
        ),
      ),
    );
  }
}
