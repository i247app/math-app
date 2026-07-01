part of '../../review_tab.dart';

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.scale});

  final String icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58 * scale,
      height: 58 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        icon,
        style: TextStyle(
          fontSize: FontSize.xxxl * scale,
          height: 1,
          color: Colors.black,
        ),
      ),
    );
  }
}
