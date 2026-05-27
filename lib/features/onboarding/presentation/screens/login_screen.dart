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
    final mascotSize = width < 370 ? 130.0 : 154.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          const Positioned.fill(child: _LoginSceneBackground()),
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
                SizedBox(height: compact ? 24 : 46),
                Center(
                  child: _LoginBrandMascot(size: mascotSize),
                ),
                SizedBox(height: compact ? 18 : 28),
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

class _LoginSceneBackground extends StatelessWidget {
  const _LoginSceneBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEFFBFC),
      child: Stack(
        children: [
          const Positioned(
            left: -30,
            top: 128,
            child: _Cloud(width: 148, opacity: 0.76),
          ),
          const Positioned(
            right: -20,
            top: 246,
            child: _Cloud(width: 128, opacity: 0.62),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LoginHillPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBrandMascot extends StatelessWidget {
  const _LoginBrandMascot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/model2.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        _NumiLogo(width: size * 0.9),
      ],
    );
  }
}

class _NumiLogo extends StatelessWidget {
  const _NumiLogo({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final fontSize = width * 0.34;

    return SizedBox(
      width: width,
      height: width * 0.47,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: _OutlinedLogoText(
              text: 'Numi',
              fontSize: fontSize,
              fill: const Color(0xFFD82683),
            ),
          ),
          Positioned(
            top: width * 0.22,
            child: _OutlinedLogoText(
              text: 'Numi',
              fontSize: fontSize,
              fill: const Color(0xFFFFD428),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedLogoText extends StatelessWidget {
  const _OutlinedLogoText({
    required this.text,
    required this.fontSize,
    required this.fill,
  });

  final String text;
  final double fontSize;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final strokeStyle = TextStyle(
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.88,
      letterSpacing: 0,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.14
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF074B91),
    );
    final fillStyle = TextStyle(
      color: fill,
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 0.88,
      letterSpacing: 0,
    );

    return Stack(
      children: [
        Text(text, style: strokeStyle),
        Text(text, style: fillStyle),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({
    required this.width,
    required this.opacity,
  });

  final double width;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(width, width * 0.44),
        painter: _CloudPainter(),
      ),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final fillPaint = Paint()..color = const Color(0xFFEAF8FB);
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.7)
      ..cubicTo(
        size.width * 0.04,
        size.height * 0.35,
        size.width * 0.27,
        size.height * 0.3,
        size.width * 0.35,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.46,
        size.height * 0.04,
        size.width * 0.76,
        size.height * 0.16,
        size.width * 0.74,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width,
        size.height * 0.48,
        size.width,
        size.height * 0.86,
        size.width * 0.78,
        size.height * 0.86,
      )
      ..lineTo(size.width * 0.16, size.height * 0.86)
      ..cubicTo(0, size.height * 0.86, 0, size.height * 0.72, size.width * 0.05,
          size.height * 0.7)
      ..close();

    canvas.drawPath(path.shift(const Offset(0, 14)), shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginHillPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF43B352);
    final path = Path()
      ..moveTo(0, size.height * 0.94)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.98,
        size.width * 0.52,
        size.height * 0.87,
        size.width * 0.76,
        size.height * 0.89,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.9,
        size.width,
        size.height * 0.93,
        size.width,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            child: canSendOtp && (isCheckingAuthPhone || isSendingOtp)
                ? const _CheckingDots(key: ValueKey('checking-phone'))
                : canSendOtp && phoneExists == false
                    ? Column(
                        key: const ValueKey('send-otp-actions'),
                        children: [
                          const Text(
                            'Đây là tài khoản MỚI. Tiếp tục đăng ký?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: 'Đăng ký',
                            onPressed: onSendOtp,
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
