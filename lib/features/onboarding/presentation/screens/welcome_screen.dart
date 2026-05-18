import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 760;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height - MediaQuery.paddingOf(context).top,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                SizedBox(height: compact ? 18 : 30),
                const Row(
                  children: [
                    BrandMark(compact: true),
                    Spacer(),
                    ProgressDots(activeIndex: 0, count: 2),
                  ],
                ),
                SizedBox(height: compact ? 30 : 54),
                RobotCard(size: compact ? 270 : 318),
                SizedBox(height: compact ? 34 : 46),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Học Toán cùng\nNUMI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: compact ? 30 : 34,
                            height: 1.04,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Hãy cùng Numi\ntrở thành "phù thủy" tính toán nhé!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: compact ? 16 : 17,
                            height: 1.32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 6,
                      top: compact ? 54 : 58,
                      child: const PlusBadge(),
                    ),
                  ],
                ),
                const Spacer(),
                WelcomePrimaryButton(label: 'BẮT ĐẦU', onPressed: onStart),
                SizedBox(height: compact ? 22 : 140),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomePrimaryButton extends StatelessWidget {
  const WelcomePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.teal, AppColors.tealLight],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withValues(alpha: 0.22),
              blurRadius: 13,
              offset: const Offset(0, 9),
            ),
          ],
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
