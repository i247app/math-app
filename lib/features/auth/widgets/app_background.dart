import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.authBackgroundStart, colors.authBackgroundEnd],
              ),
            ),
          ),
        ),
        const Positioned(
          left: -150,
          bottom: -54,
          child: _BackgroundRing(size: 220),
        ),
        const Positioned(
          right: -48,
          bottom: -28,
          child: _BackgroundCircle(size: 155),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _BackgroundRing extends StatelessWidget {
  const _BackgroundRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.authDecorRing, width: 38),
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.authDecorCircle,
      ),
    );
  }
}
