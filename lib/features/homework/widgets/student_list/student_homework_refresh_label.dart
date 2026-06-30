part of '../../presentation/student_homework_screen.dart';

class _StudentHomeworkRefreshLabel extends StatelessWidget {
  const _StudentHomeworkRefreshLabel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        context.getText(AppKeys.loading),
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: _studentHomeworkMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
