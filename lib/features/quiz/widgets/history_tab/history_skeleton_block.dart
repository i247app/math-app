part of '../../history_tab.dart';

class _HistorySkeletonBlock extends StatelessWidget {
  const _HistorySkeletonBlock({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE3EAEC),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
