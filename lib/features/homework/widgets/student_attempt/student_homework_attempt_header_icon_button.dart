part of '../../presentation/student_homework_attempt_screen.dart';

class _StudentHomeworkAttemptHeaderIconButton extends StatelessWidget {
  const _StudentHomeworkAttemptHeaderIconButton({
    required this.icon,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 34 * scale,
          height: 34 * scale,
          child: Icon(icon, color: _homeworkAttemptTeal, size: 22 * scale),
        ),
      ),
    );
  }
}
