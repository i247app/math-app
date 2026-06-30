part of '../../presentation/student_homework_result_screen.dart';

class _StudentHomeworkResultHeaderIconButton extends StatelessWidget {
  const _StudentHomeworkResultHeaderIconButton({
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
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 40 * scale,
          height: 40 * scale,
          child: Icon(icon, color: _homeworkResultHeaderTeal, size: 23 * scale),
        ),
      ),
    );
  }
}
