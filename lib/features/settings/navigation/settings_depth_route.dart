import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class SettingsDepthRoute<T> extends PageRouteBuilder<T> {
  SettingsDepthRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 430),
        reverseTransitionDuration: const Duration(milliseconds: 430),
        opaque: false,
        allowSnapshotting: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return _SettingsPageSlide(
            animation: animation,
            incoming: true,
            child: child,
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
    return ColoredBox(
      color: context.themeColors.pageBackground,
      child: _SettingsPageSlide(
        animation: secondaryAnimation,
        incoming: false,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class _SettingsPageSlide extends StatelessWidget {
  const _SettingsPageSlide({
    required this.animation,
    required this.incoming,
    required this.child,
  });

  final Animation<double> animation;
  final bool incoming;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final isReversing = animation.status == AnimationStatus.reverse;
              final elapsed = isReversing
                  ? 1 - animation.value
                  : animation.value;
              final progress = Curves.easeOutCubic.transform(elapsed);
              final distance = switch ((incoming, isReversing)) {
                (true, false) => 1 - progress,
                (true, true) => progress,
                (false, false) => -progress,
                (false, true) => -(1 - progress),
              };

              return Transform.translate(
                offset: Offset(constraints.maxWidth * distance, 0),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
