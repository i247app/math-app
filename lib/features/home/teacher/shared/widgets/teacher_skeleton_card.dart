part of '../../../../classroom/presentation/teacher_classroom_screens.dart';

class _TeacherSkeletonCard extends StatefulWidget {
  const _TeacherSkeletonCard({
    required this.scale,
    required this.padding,
    required this.child,
  });

  final double scale;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  State<_TeacherSkeletonCard> createState() => _TeacherSkeletonCardState();
}

class _TeacherSkeletonCardState extends State<_TeacherSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1250),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _TeacherSkeletonShimmer(
      controller: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24 * widget.scale),
          border: Border.all(color: const Color(0x33C4C6D2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A002B6A),
              blurRadius: 20 * widget.scale,
              spreadRadius: -4 * widget.scale,
              offset: Offset(0, 4 * widget.scale),
            ),
          ],
        ),
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}
