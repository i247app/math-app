import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/otp_auth_api.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.user,
    required this.onBack,
  });

  final LoginUser? user;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final name = user?.name?.trim();
    final phone = user?.phone?.trim();
    final height = MediaQuery.sizeOf(context).height;

    return ScreenFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
          SizedBox(height: height < 760 ? 120 : 170),
          Text(
            'Home page',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: MediaQuery.sizeOf(context).width < 370 ? 32 : 36,
              height: 1.04,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name?.isNotEmpty == true
                ? 'Chào mừng $name trở lại NUMI.'
                : 'Đăng nhập thành công.',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 16,
              height: 1.42,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          if (phone?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              phone!,
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 18,
                height: 1.3,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
