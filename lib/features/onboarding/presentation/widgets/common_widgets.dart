import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.child,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  final Widget child;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontalPadding = width < 370 ? 24.0 : 32.0;

    return LayoutBuilder(
      builder: (context, _) {
        return SingleChildScrollView(
          keyboardDismissBehavior: keyboardDismissBehavior,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: enabled ? 1 : 0.55),
              AppColors.tealLight.withValues(alpha: enabled ? 1 : 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      elevation: 2,
      shadowColor: AppColors.greenShadow,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppColors.teal, size: size * 0.52),
        ),
      ),
    );
  }
}

class ProgressDots extends StatelessWidget {
  const ProgressDots({
    super.key,
    required this.activeIndex,
    this.count = 4,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(count, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: active ? 20 : 7,
            height: 7,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.teal
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(999),
              border: active
                  ? null
                  : Border.all(color: AppColors.teal.withValues(alpha: 0.16)),
            ),
          );
        }),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 28.0 : 34.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalculatorIcon(size: iconSize),
        const SizedBox(width: 10),
        Text(
          'NUMI',
          style: TextStyle(
            color: AppColors.teal,
            fontSize: compact ? 24 : 30,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class CalculatorIcon extends StatelessWidget {
  const CalculatorIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(size * 0.18),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final symbol in ['+', 'x', '-', '='])
            Text(
              symbol,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.32,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class NumiMascot extends StatelessWidget {
  const NumiMascot({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.coral, AppColors.coralLight],
              ),
              borderRadius: BorderRadius.circular(size * 0.18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Positioned(
            left: -12,
            top: size * 0.28,
            child: const MathBubble(text: '2 + 3 = 5'),
          ),
          Positioned(
            right: -10,
            top: size * 0.16,
            child: const MathBubble(text: '4 x 2 = 8'),
          ),
          Container(
            width: size * 0.54,
            height: size * 0.66,
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(size * 0.18),
              border: Border.all(color: AppColors.teal, width: 4),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: size * 0.16,
                  left: size * 0.13,
                  child: const RobotEye(),
                ),
                Positioned(
                  top: size * 0.16,
                  right: size * 0.13,
                  child: const RobotEye(),
                ),
                Positioned(
                  bottom: size * 0.18,
                  child: Container(
                    width: size * 0.18,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MathBubble extends StatelessWidget {
  const MathBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.teal,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class RobotEye extends StatelessWidget {
  const RobotEye({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 17,
          height: 17,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class VietnamFlag extends StatelessWidget {
  const VietnamFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.vietnamRed,
        borderRadius: BorderRadius.circular(2),
      ),
      child: const Icon(Icons.star, color: Colors.yellow, size: 11),
    );
  }
}
