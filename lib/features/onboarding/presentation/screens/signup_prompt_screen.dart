import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class SignupPromptScreen extends StatelessWidget {
  const SignupPromptScreen({
    super.key,
    required this.phoneNumber,
    required this.onBack,
    required this.onContinue,
  });

  final String? phoneNumber;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;
    final phone = phoneNumber?.trim();

    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
              const Spacer(),
              const ProgressDots(activeIndex: 1),
            ],
          ),
          SizedBox(height: compact ? 64 : 98),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.ink,
                fontSize: tight ? 30 : 34,
                height: 1.04,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
              children: const [
                TextSpan(text: 'Tạo '),
                TextSpan(
                  text: 'tài khoản',
                  style: TextStyle(color: AppColors.teal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Số điện thoại này chưa tồn tại trong hệ thống NUMI.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.42,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: compact ? 26 : 30),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tight ? 20 : 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.greenShadow,
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SỐ ĐIỆN THOẠI',
                  style: TextStyle(
                    color: AppColors.grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  phone?.isNotEmpty == true ? phone! : 'Chưa có số điện thoại',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tiếp tục để xác minh OTP và tạo hồ sơ học tập cho bé.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Tiếp tục',
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
