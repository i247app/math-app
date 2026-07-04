part of '../../practice_tab.dart';

class PracticeDepthButtonSurface extends StatelessWidget {
  const PracticeDepthButtonSurface({
    super.key,
    required this.radius,
    required this.depth,
    required this.padding,
    required this.child,
  });

  final double radius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: _testShadow),
        child: Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _testYellow,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: padding,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
