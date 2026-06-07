import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
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
    required this.canLoginWithPin,
    required this.onLoginWithPin,
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
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final ValueChanged<String> onPhoneChanged;
  final bool? phoneExists;
  final String? phoneErrorText;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final mascotSize = width < 370 ? 160.0 : 200.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ScreenFrame(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
              SizedBox(height: compact ? 12 : 24),
              // Mascot
              Center(
                child: Container(
                  width: mascotSize,
                  height: mascotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/numi-mascot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: compact ? 16 : 24),
              // Title
              Center(
                child: Text(
                  context.getText(AppKeys.phoneLoginBrandName),
                  style: GoogleFonts.andika(
                    color: const Color(0xFF339395),
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Center(
                child: Text(
                  context.getText(AppKeys.phoneLoginSubtitle),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.andika(
                    color: const Color(0xFF1B1B1B),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: compact ? 32 : 48),
              // Input & Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LoginCard(
                  controller: controller,
                  region: region,
                  onRegionChanged: onRegionChanged,
                  onSendOtp: onSendOtp,
                  isSendingOtp: isSendingOtp,
                  isCheckingAuthPhone: isCheckingAuthPhone,
                  canSendOtp: canSendOtp,
                  canLoginWithPin: canLoginWithPin,
                  onLoginWithPin: onLoginWithPin,
                  onPhoneChanged: onPhoneChanged,
                  phoneExists: phoneExists,
                  phoneErrorText: phoneErrorText,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
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
    required this.canLoginWithPin,
    required this.onLoginWithPin,
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
  final bool canLoginWithPin;
  final VoidCallback onLoginWithPin;
  final ValueChanged<String> onPhoneChanged;
  final bool? phoneExists;
  final String? phoneErrorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Input
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB5BFC2), width: 1.5),
          ),
          child: Row(
            children: [
              PhoneRegionMenu(
                region: region,
                onChanged: onRegionChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 1,
                  height: 24,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              Expanded(
                child: TextField(
                  key: ValueKey(region),
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofillHints: null,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableIMEPersonalizedLearning: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneInputFormatter(region),
                  ],
                  onChanged: onPhoneChanged,
                  decoration: InputDecoration(
                    hintText: region.hint,
                    hintStyle: GoogleFonts.andika(
                      color: const Color(0xFFB9C2C5),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: GoogleFonts.andika(
                    color: AppColors.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
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
              ? const SizedBox(height: 24)
              : Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
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
        // Actions
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: canSendOtp && (isCheckingAuthPhone || isSendingOtp)
              ? const _CheckingDots(key: ValueKey('checking-phone'))
              : (canSendOtp)
                  ? _GreyActionButton(
                      label: phoneExists == false
                          ? context.getText(AppKeys.signup)
                          : context.getText(AppKeys.login),
                      onPressed: onSendOtp,
                    )
                  : const SizedBox(
                      key: ValueKey('send-otp-placeholder'),
                      height: 56, // same height as button to prevent jumping
                    ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: canLoginWithPin
              ? Padding(
                  key: const ValueKey('login-with-pin'),
                  padding: const EdgeInsets.only(top: 18),
                  child: Center(
                    child: InkWell(
                      onTap: onLoginWithPin,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Text(
                          context.getText(AppKeys.loginWithPin),
                          style: GoogleFonts.andika(
                            color: const Color(0xFF001741),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 20 / 16,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF001741),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-pin-login')),
        ),
      ],
    );
  }
}

class _GreyActionButton extends StatelessWidget {
  const _GreyActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF339395),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.andika(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 24),
          ],
        ),
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
      height: 64, // Matches button height
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
                      color: const Color(0xFF798B8C).withValues(alpha: opacity),
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
      offset: const Offset(0, 48),
      itemBuilder: (context) {
        return PhoneRegion.values.map((item) {
          return PopupMenuItem(
            value: item,
            child: Text(
              '${item.flag}  ${item.label} ${item.code}',
              style: GoogleFonts.andika(),
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(region.flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            region.code,
            style: GoogleFonts.andika(
              color: const Color(0xFF323B3E),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
