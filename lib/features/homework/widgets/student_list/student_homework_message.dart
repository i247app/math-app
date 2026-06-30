part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkMessage extends StatelessWidget {
  const _StudentHomeworkMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: _studentHomeworkMuted,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 22 / 15,
        ),
      ),
    );
  }
}
