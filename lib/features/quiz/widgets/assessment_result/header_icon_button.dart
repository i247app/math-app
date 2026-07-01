part of '../../presentation/assessment_result_screen.dart';

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
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
          child: Icon(icon, color: _resultHeaderTeal, size: 23 * scale),
        ),
      ),
    );
  }
}
