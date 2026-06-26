part of '../../../home_screen.dart';

class _StudentLoadingPanel extends StatelessWidget {
  const _StudentLoadingPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 132 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: SizedBox(
        width: 26 * scale,
        height: 26 * scale,
        child: const CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}
