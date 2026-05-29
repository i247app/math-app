import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../domain/phone_region.dart';
import '../widgets/common_widgets.dart';
import '../widgets/login_scene_background.dart';
import '../widgets/numi_brand_mascot.dart';

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
    final mascotSize = width < 370 ? 200.0 : 260.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          const Positioned.fill(child: LoginSceneBackground()),
          ScreenFrame(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: onBack,
                ),
                SizedBox(height: compact ? 8 : 24),
                Center(
                  child: NumiBrandMascot(size: mascotSize),
                ),
                SizedBox(height: compact ? 10 : 18),
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
                const SizedBox(height: 92),
              ],
            ),
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              context.getText(AppKeys.phoneNumberUpper),
              style: const TextStyle(
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
            child: canSendOtp && (isCheckingAuthPhone || isSendingOtp)
                ? const _CheckingDots(key: ValueKey('checking-phone'))
                : canSendOtp && phoneExists == false
                    ? Column(
                        key: const ValueKey('send-otp-actions'),
                        children: [
                          Text(
                            context.getText(AppKeys.newAccountPrompt),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: context.getText(AppKeys.signup),
                            onPressed: onSendOtp,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              width: 255,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 20,
                                    color: AppColors.orangeAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      context.getText(
                                        AppKeys.otpWithin30Seconds,
                                      ),
                                      style: const TextStyle(
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
                    : canSendOtp && phoneExists == true
                        ? Column(
                            key: const ValueKey('login-otp-actions'),
                            children: [
                              PrimaryButton(
                                label: context.getText(AppKeys.login),
                                onPressed: onSendOtp,
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

class _CheckingDots extends StatefulWidget {
  const _CheckingDots({super.key});

  @override
  State<_CheckingDots> createState() => _CheckingDotsState();
}

class _CheckingDotsState extends State<_CheckingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('checking-phone-dots'),
      height: 58,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final progress = (controller.value + index * 0.22) % 1;
                final opacity = 0.35 + 0.65 * (1 - (progress - 0.5).abs() * 2);
                final lift = -7 * (1 - (progress - 0.5).abs() * 2);

                return Transform.translate(
                  offset: Offset(0, lift),
                  child: Container(
                    width: 9,
                    height: 9,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            );
          },
        ),
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
      tooltip: context.getText(AppKeys.chooseCountry),
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
