part of '../../presentation/teacher_homework_screen.dart';

class TeacherEmptyAssignmentsPanel extends StatelessWidget {
  const TeacherEmptyAssignmentsPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9EC)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: teacherMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
