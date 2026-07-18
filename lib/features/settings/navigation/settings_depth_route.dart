import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class SettingsDepthRoute<T> extends PageRouteBuilder<T> {
  SettingsDepthRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        opaque: false,
        allowSnapshotting: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final isReversing = animation.status == AnimationStatus.reverse;
              final progress =
                  (isReversing ? Curves.easeInCubic : Curves.easeOutCubic)
                      .transform(animation.value);
              if (isReversing) {
                return Opacity(opacity: progress, child: child);
              }
              return child ?? const SizedBox.shrink();
            },
          );
        },
      );

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _buildDelegatedTransition;

  static Widget? _buildDelegatedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      child: child,
      builder: (context, child) {
        final isReversing =
            secondaryAnimation.status == AnimationStatus.reverse;
        final progress =
            (isReversing ? Curves.easeInCubic : Curves.easeOutCubic).transform(
              secondaryAnimation.value,
            );
        if (isReversing) {
          return ColoredBox(
            color: context.themeColors.pageBackground,
            child: Transform.scale(
              scale: 1 + (0.14 * progress),
              alignment: Alignment.center,
              child: child,
            ),
          );
        }

        return ColoredBox(
          color: context.themeColors.pageBackground,
          child: Transform.scale(
            scale: 1 - (0.12 * progress),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}
