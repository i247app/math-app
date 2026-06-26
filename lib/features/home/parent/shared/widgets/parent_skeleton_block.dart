part of '../../../home_screen.dart';

class _ParentSkeletonBlock extends StatelessWidget {
  const _ParentSkeletonBlock({
    this.width,
    this.height,
    required this.radius,
    required this.color,
    this.child,
  });

  final double? width;
  final double? height;
  final double radius;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE8ECEB)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
