import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final short = height < 680;
    final tight = width < 370;

    return ScreenFrame(
      child: Column(
        children: [
          SizedBox(
              height: short
                  ? 12
                  : compact
                      ? 18
                      : 26),
          const Row(
            children: [
              BrandMark(compact: true),
              Spacer(),
              ProgressDots(activeIndex: 0),
            ],
          ),
          SizedBox(
              height: short
                  ? 18
                  : compact
                      ? 28
                      : 46),
          NumiMascot(
              size: short
                  ? 186
                  : tight
                      ? 218
                      : compact
                          ? 238
                          : 270),
          SizedBox(
              height: short
                  ? 20
                  : compact
                      ? 30
                      : 40),
          Text(
            'Học Toán cùng\nNUMI',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: short
                  ? 28
                  : tight
                      ? 30
                      : 34,
              height: 1.02,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Hãy cùng Numi trở thành\ncao thủ tính toán nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: short
                  ? 15
                  : tight
                      ? 16
                      : 17,
              height: 1.32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          SizedBox(
              height: short
                  ? 24
                  : compact
                      ? 34
                      : 52),
          PrimaryButton(label: 'BẮT ĐẦU', onPressed: onStart),
          SizedBox(
              height: short
                  ? 18
                  : compact
                      ? 24
                      : 44),
        ],
      ),
    );
  }
}
