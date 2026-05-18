import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.skyMint,
                Color(0xFFF2FFF2),
                AppColors.mintMist,
              ],
            ),
          ),
          child: SizedBox.expand(),
        ),
        const Positioned(
          left: -76,
          bottom: -96,
          child: _BackgroundRing(size: 190),
        ),
        const Positioned(
          right: -54,
          bottom: -44,
          child: _BackgroundCircle(size: 142),
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD8DAC6).withValues(alpha: 0.62),
          width: 20,
        ),
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.skyMint.withValues(alpha: 0.78),
      ),
    );
  }
}
