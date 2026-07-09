import 'package:flutter/material.dart';

import 'package:numi/features/home/shared/widgets/home_skeleton_shimmer.dart';

/// A self-animating card that wraps content with a shimmer loading effect.
///
/// Replaces [TeacherSkeletonCard]: manages its own [AnimationController]
/// and applies [HomeSkeletonShimmer] around a decorated container.
class HomeSkeletonCard extends StatefulWidget {
  const HomeSkeletonCard({
    super.key,
    required this.scale,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.color = Colors.white,
    this.borderColor = const Color(0x33C4C6D2),
    this.animationDuration = const Duration(milliseconds: 1250),
  });

  final double scale;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final Color color;
  final Color borderColor;
  final Duration animationDuration;

  @override
  State<HomeSkeletonCard> createState() => _HomeSkeletonCardState();
}

class _HomeSkeletonCardState extends State<HomeSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.animationDuration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 24 * widget.scale;
    return HomeSkeletonShimmer(
      controller: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: widget.borderColor),
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
