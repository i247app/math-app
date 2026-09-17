import 'package:flutter/material.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/welcome/widgets/welcome_start_button.dart';

class WelcomeDetailsControls extends StatelessWidget {
  const WelcomeDetailsControls({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 28,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Row(
          children: [
            const _PageIndicator(),
            const Spacer(),
            SizedBox(
              width: 143,
              child: WelcomeStartButton(
                onStart: onStart,
                labelKey: AppKeys.continueUpper,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IndicatorDot(color: colors.welcomeInactiveDot),
        const SizedBox(width: 8),
        Container(
          width: 24,
          height: 8,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        _IndicatorDot(color: colors.welcomeInactiveDot),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
