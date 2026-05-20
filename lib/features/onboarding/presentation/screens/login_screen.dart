import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../domain/phone_region.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
    required this.onBack,
    required this.onSendOtp,
    required this.isSendingOtp,
    required this.isCheckingAuthPhone,
    required this.canSendOtp,
    required this.onPhoneChanged,
    this.phoneExists,
    this.phoneErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onBack;
  final VoidCallback onSendOtp;
  final bool isSendingOtp;
  final bool isCheckingAuthPhone;
  final bool canSendOtp;
  final ValueChanged<String> onPhoneChanged;
  final bool? phoneExists;
  final String? phoneErrorText;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ScreenFrame(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  TextSpan(text: 'Xác minh '),
                  TextSpan(
                    text: 'tài khoản',
                    style: TextStyle(color: AppColors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Vui lòng nhập số điện thoại để tiếp tục hành trình học tập cùng Numi.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: tight ? 15 : 16,
                height: 1.42,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: compact ? 26 : 30),
            LoginCard(
              controller: controller,
              region: region,
              onRegionChanged: onRegionChanged,
              onSendOtp: onSendOtp,
              isSendingOtp: isSendingOtp,
              isCheckingAuthPhone: isCheckingAuthPhone,
              canSendOtp: canSendOtp,
              onPhoneChanged: onPhoneChanged,
              phoneExists: phoneExists,
              phoneErrorText: phoneErrorText,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
    required this.onSendOtp,
    required this.isSendingOtp,
    required this.isCheckingAuthPhone,
    required this.canSendOtp,
    required this.onPhoneChanged,
    this.phoneExists,
    this.phoneErrorText,
  });

  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;
  final VoidCallback onSendOtp;
  final bool isSendingOtp;
  final bool isCheckingAuthPhone;
  final bool canSendOtp;
  final ValueChanged<String> onPhoneChanged;
  final bool? phoneExists;
  final String? phoneErrorText;

  String get _buttonLabel {
    if (isSendingOtp) {
      return 'Đang xử lý...';
    }

    if (isCheckingAuthPhone) {
      return 'Đang kiểm tra...';
    }

    return 'Đăng ký';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final tight = width < 370;

    return Container(
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
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Text(
              'SỐ ĐIỆN THOẠI',
              style: TextStyle(
                color: AppColors.grayText,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.inputLine),
            ),
            child: Row(
              children: [
                PhoneRegionMenu(
                  region: region,
                  onChanged: onRegionChanged,
                ),
                const SizedBox(width: 10),
                Text(
                  region.code,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: ValueKey(region),
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneInputFormatter(region),
                    ],
                    onChanged: onPhoneChanged,
                    decoration: InputDecoration(
                      hintText: region.hint,
                      hintStyle: const TextStyle(color: Color(0xFFC8CFCB)),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: phoneErrorText == null
                ? const SizedBox(height: 18)
                : Padding(
                    padding: const EdgeInsets.only(top: 10, left: 6),
                    child: Text(
                      phoneErrorText!,
                      style: const TextStyle(
                        color: Color(0xFFD9534F),
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: canSendOtp &&
                    (phoneExists == false ||
                        isSendingOtp ||
                        isCheckingAuthPhone)
                ? Column(
                    key: const ValueKey('send-otp-actions'),
                    children: [
                      PrimaryButton(
                        label: _buttonLabel,
                        onPressed: isSendingOtp || isCheckingAuthPhone
                            ? null
                            : onSendOtp,
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: SizedBox(
                          width: 255,
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 20,
                                color: AppColors.orangeAccent,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Bạn sẽ nhận được mã trong vòng 30 giây',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                    height: 1.28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(
                    key: ValueKey('send-otp-placeholder'),
                    height: 0,
                  ),
          ),
        ],
      ),
    );
  }
}

class PhoneRegionMenu extends StatelessWidget {
  const PhoneRegionMenu({
    super.key,
    required this.region,
    required this.onChanged,
  });

  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PhoneRegion>(
      tooltip: 'Chọn quốc gia',
      onSelected: onChanged,
      itemBuilder: (context) {
        return PhoneRegion.values.map((item) {
          return PopupMenuItem(
            value: item,
            child: Text('${item.flag}  ${item.label} ${item.code}'),
          );
        }).toList();
      },
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.mintMist,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(region.flag, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.grayText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
