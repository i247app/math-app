import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/shared/widgets/skeleton/app_skeleton_shimmer.dart';

/// A self-animating card that wraps content with a shimmer loading effect.
///
/// Replaces [TeacherSkeletonCard]: manages its own [AnimationController]
/// and applies [AppSkeletonShimmer] around a decorated container.
class AppSkeletonCard extends StatefulWidget {
  const AppSkeletonCard({
    super.key,
    this.scale = 1,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
    this.color,
    this.borderColor,
    this.animationDuration = const Duration(milliseconds: 1250),
  });

  final double scale;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final Duration animationDuration;

  @override
  State<AppSkeletonCard> createState() => _AppSkeletonCardState();
}

class _AppSkeletonCardState extends State<AppSkeletonCard>
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
    final colors = context.themeColors;
    final radius = widget.borderRadius ?? 24 * widget.scale;
    return AppSkeletonShimmer(
      controller: _controller,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.color ?? colors.elevatedSurface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: widget.borderColor ?? colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
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
