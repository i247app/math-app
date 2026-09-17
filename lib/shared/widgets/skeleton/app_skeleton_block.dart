import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

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
    this.color,
    this.child,
    this.outlined = false,
  });

  final double? width;
  final double? height;
  final double radius;

  /// Fill color. In [outlined] mode this is the inner overlay color.
  final Color? color;

  final Widget? child;

  /// When `true`, wraps the block in a white card with border (parent style).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final resolvedColor = color ?? colors.skeleton;
    if (!outlined) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: resolvedColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: colors.border),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedColor.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}
