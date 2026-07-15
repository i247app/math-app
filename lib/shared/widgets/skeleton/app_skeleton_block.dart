import 'package:flutter/material.dart';

/// A simple rounded rectangle used as a skeleton placeholder block.
///
/// Replaces both [TeacherSkeletonBlock] (simple colored rect) and
/// [_ParentSkeletonBlock] (card with white outer + inner colored layer).
///
/// Set [outlined] to `true` to render the parent-style card variant with
/// a white background, border, and a semi-transparent inner color layer.
class AppSkeletonBlock extends StatelessWidget {
  const AppSkeletonBlock({
    super.key,
    this.width,
    this.height,
    required this.radius,
    this.color = const Color(0xFFF3F7FA),
    this.child,
    this.outlined = false,
  });

  final double? width;
  final double? height;
  final double radius;

  /// Fill color. In [outlined] mode this is the inner overlay color.
  final Color color;

  final Widget? child;

  /// When `true`, wraps the block in a white card with border (parent style).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (!outlined) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
    }

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
