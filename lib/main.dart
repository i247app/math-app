import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NumiApp());
}

class NumiApp extends StatelessWidget {
  const NumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUMI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
        fontFamily: 'System',
        useMaterial3: true,
      ),
      home: const NumiHome(),
    );
  }
}

class NumiHome extends StatefulWidget {
  const NumiHome({super.key});

  @override
  State<NumiHome> createState() => _NumiHomeState();
}

class _NumiHomeState extends State<NumiHome> {
  AppScreen screen = AppScreen.welcome;
  bool didSendCode = false;
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void goToLogin() {
    setState(() => screen = AppScreen.login);
  }

  void goToWelcome() {
    setState(() => screen = AppScreen.welcome);
  }

  void goToOtp() {
    setState(() => screen = AppScreen.otp);
  }

  void sendOtp() {
    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      HapticFeedback.selectionClick();
      return;
    }

    setState(() {
      didSendCode = true;
      screen = AppScreen.otp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AppBackground(
          child: SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final offset = Tween<Offset>(
                  begin: screen == AppScreen.welcome
                      ? const Offset(-0.08, 0)
                      : const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: switch (screen) {
                AppScreen.welcome => WelcomeScreen(
                    key: const ValueKey('welcome'),
                    onStart: goToLogin,
                  ),
                AppScreen.login => LoginScreen(
                    key: const ValueKey('login'),
                    controller: phoneController,
                    didSendCode: didSendCode,
                    onBack: goToWelcome,
                    onSendOtp: sendOtp,
                    onChanged: () => setState(() => didSendCode = false),
                  ),
                AppScreen.otp => OtpScreen(
                    key: const ValueKey('otp'),
                    onBack: goToLogin,
                    onConfirm: () => HapticFeedback.mediumImpact(),
                    onResend: goToOtp,
                  ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum AppScreen {
  welcome,
  login,
  otp,
}

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
            minHeight: height - MediaQuery.paddingOf(context).top),
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
                    ProgressDots(activeIndex: 0),
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
                            fontSize: compact ? 36 : 42,
                            height: 0.98,
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
                            fontSize: compact ? 19 : 22,
                            height: 1.24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 6,
                      top: compact ? 64 : 72,
                      child: const PlusBadge(),
                    ),
                  ],
                ),
                const Spacer(),
                PrimaryButton(label: 'BẮT ĐẦU', onPressed: onStart),
                SizedBox(height: compact ? 22 : 140),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.didSendCode,
    required this.onBack,
    required this.onSendOtp,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool didSendCode;
  final VoidCallback onBack;
  final VoidCallback onSendOtp;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 760;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: height - MediaQuery.paddingOf(context).top),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: compact ? 18 : 30),
              Row(
                children: [
                  CircleIconButton(
                      icon: Icons.arrow_back_rounded, onPressed: onBack),
                  const Spacer(),
                  const ProgressDots(activeIndex: 1),
                ],
              ),
              SizedBox(height: compact ? 74 : 130),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 38,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                  children: [
                    TextSpan(text: 'Xác minh '),
                    TextSpan(
                        text: 'tài khoản',
                        style: TextStyle(color: AppColors.teal)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vui lòng nhập số điện thoại để tiếp tục hành trình học tập cùng Numi.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: compact ? 18 : 20,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: compact ? 26 : 34),
              LoginCard(
                controller: controller,
                didSendCode: didSendCode,
                onSendOtp: onSendOtp,
                onChanged: onChanged,
              ),
              const SizedBox(height: 28),
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
    required this.didSendCode,
    required this.onSendOtp,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool didSendCode;
  final VoidCallback onSendOtp;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            blurRadius: 24,
            offset: Offset(0, 16),
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
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.inputLine),
            ),
            child: Row(
              children: [
                const VietnamFlag(),
                const SizedBox(width: 14),
                const Text(
                  '+84',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [PhoneInputFormatter()],
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(
                      hintText: '090 123 4567',
                      hintStyle: TextStyle(color: Color(0xFFC8CFCB)),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          PrimaryButton(
            label: didSendCode ? 'Đã gửi mã OTP' : 'Gửi mã OTP  →',
            onPressed: didSendCode ? null : onSendOtp,
          ),
          const SizedBox(height: 18),
          const Center(
            child: SizedBox(
              width: 270,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 20, color: AppColors.orangeAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn sẽ nhận được mã trong vòng 30 giây',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 16,
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
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.onBack,
    required this.onConfirm,
    required this.onResend,
  });

  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final VoidCallback onResend;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get canConfirm =>
      controllers.every((controller) => controller.text.isNotEmpty);

  void updateDigit(int index, String value) {
    final digit = value.replaceAll(RegExp(r'\D'), '');
    if (digit.isEmpty) {
      controllers[index].clear();
      setState(() {});
      return;
    }

    controllers[index].text = digit.substring(digit.length - 1);
    controllers[index].selection = const TextSelection.collapsed(offset: 1);

    if (index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }

    setState(() {});
  }

  void handleConfirm() {
    if (!canConfirm) {
      HapticFeedback.selectionClick();
      return;
    }

    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 760;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: height - MediaQuery.paddingOf(context).top),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: compact ? 18 : 28),
              CircleIconButton(
                  icon: Icons.arrow_back_rounded, onPressed: widget.onBack),
              SizedBox(height: compact ? 166 : 90),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 40,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                  children: [
                    TextSpan(text: 'Xác thực '),
                    TextSpan(
                        text: 'OTP', style: TextStyle(color: AppColors.teal)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Vui lòng nhập mã 4 số đã được gửi đến số điện thoại của bạn.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 21,
                  height: 1.48,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: compact ? 36 : 48),
              OtpCard(
                controllers: controllers,
                focusNodes: focusNodes,
                canConfirm: canConfirm,
                onChanged: updateDigit,
                onConfirm: handleConfirm,
                onResend: widget.onResend,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpCard extends StatelessWidget {
  const OtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.canConfirm,
    required this.onChanged,
    required this.onConfirm,
    required this.onResend,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool canConfirm;
  final void Function(int index, String value) onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(48, 38, 48, 42),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            blurRadius: 32,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MÃ XÁC NHẬN',
            style: TextStyle(
              color: AppColors.grayText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              4,
                  (index) => SizedBox(
                width: 60, // hoặc nhỏ hơn tùy màn hình
                    child: OtpDigitBox(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  onChanged: (value) => onChanged(index, value),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          PrimaryButton(label: 'Xác nhận  →', onPressed: onConfirm),
          const SizedBox(height: 26),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TimerBadge(),
                SizedBox(width: 12),
                Text(
                  'Gửi lại mã sau 30 giây',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.softTeal,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'GỬI LẠI MÃ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpDigitBox extends StatelessWidget {
  const OtpDigitBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.58),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.inputLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
          ),
          hintText: '•',
          hintStyle: const TextStyle(
            color: Color(0xFFC6CCC8),
            fontSize: 38,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class TimerBadge extends StatelessWidget {
  const TimerBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: AppColors.timerBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Icon(Icons.timer_outlined,
          size: 18, color: AppColors.orangeAccent),
    );
  }
}

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.aquaMist, AppColors.mintMist],
            ),
          ),
        ),
        Positioned(
          left: -150,
          bottom: -54,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sandRing, width: 38),
            ),
          ),
        ),
        Positioned(
          right: -48,
          bottom: -28,
          child: Container(
            width: 155,
            height: 155,
            decoration: BoxDecoration(
              color: AppColors.aquaSoft.withValues(alpha: 0.36),
              shape: BoxShape.circle,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 50.0;

    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 10 : 12, compact ? 7 : 8,
          compact ? 13 : 16, compact ? 7 : 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScanCubeIcon(size: iconSize),
          const SizedBox(width: 8),
          CalculatorIcon(size: iconSize - 5),
          const SizedBox(width: 8),
          Text(
            'NUMI',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: compact ? 29 : 39,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(2, (index) {
          final active = index == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: active ? 22 : 8,
            height: 8,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.teal
                  : Colors.white.withValues(alpha: 0.72),
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

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      height: 68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: enabled ? 1 : 0.58),
              AppColors.tealLight.withValues(alpha: enabled ? 1 : 0.58),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.22),
                    blurRadius: 13,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
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
  const CircleIconButton(
      {super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.78),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.teal, size: 25),
        ),
      ),
    );
  }
}

class PlusBadge extends StatelessWidget {
  const PlusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.softBlue, width: 5),
      ),
      child: const Text(
        '+',
        style: TextStyle(
          color: AppColors.softBlue,
          fontSize: 38,
          height: 0.9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class RobotCard extends StatelessWidget {
  const RobotCard({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.coral, AppColors.coralLight],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: size * 0.14,
            bottom: -size * 0.1,
            child: CustomPaint(
              size: Size(size * 0.18, size * 0.1),
              painter: BookmarkPainter(),
            ),
          ),
          Positioned(
            left: -size * 0.18,
            bottom: size * 0.22,
            child: Transform.rotate(
              angle: -0.24,
              child: const MathBubble(
                  text: '2 × 2 = 4',
                  foreground: AppColors.mathInk,
                  background: AppColors.peach),
            ),
          ),
          Positioned(
            right: -size * 0.12,
            top: size * 0.18,
            child: Transform.rotate(
              angle: 0.12,
              child: const MathBubble(
                  text: '5 + 3 = 8',
                  foreground: AppColors.teal,
                  background: Colors.white),
            ),
          ),
          Center(
            child: Transform.translate(
              offset: Offset(0, size * 0.04),
              child: Robot(width: size * 0.56),
            ),
          ),
        ],
      ),
    );
  }
}

class MathBubble extends StatelessWidget {
  const MathBubble({
    super.key,
    required this.text,
    required this.foreground,
    required this.background,
  });

  final String text;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 28,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class Robot extends StatelessWidget {
  const Robot({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final w = width;

    return SizedBox(
      width: w,
      height: w * 1.28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: w * 0.06,
            child: Container(
              width: w * 0.84,
              height: w * 0.13,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            bottom: w * 0.12,
            child: Container(
              width: w * 0.6,
              height: w * 0.42,
              decoration: robotDecoration(w * 0.16),
              child: Center(
                child: Container(
                  width: w * 0.32,
                  height: w * 0.1,
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.deepTeal, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      5,
                      (_) => Container(width: 4, color: AppColors.coral),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: w * 0.02,
            bottom: w * 0.02,
            child: const RobotArm(left: true),
          ),
          Positioned(
            right: w * 0.02,
            bottom: w * 0.02,
            child: const RobotArm(left: false),
          ),
          Positioned(
            top: w * 0.08,
            child: Container(
              width: w * 0.82,
              height: w * 0.66,
              decoration: robotDecoration(w * 0.25),
            ),
          ),
          Positioned(top: w * 0.28, left: w * 0.22, child: const RobotEye()),
          Positioned(top: w * 0.28, right: w * 0.22, child: const RobotEye()),
          Positioned(
            top: w * 0.5,
            left: w * 0.32,
            child: Container(
              width: w * 0.11,
              height: w * 0.045,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: w * 0.5,
            child: CustomPaint(
              size: Size(w * 0.18, w * 0.09),
              painter: SmilePainter(),
            ),
          ),
          Positioned(left: 0, top: w * 0.32, child: const RobotEar()),
          Positioned(right: 0, top: w * 0.32, child: const RobotEar()),
        ],
      ),
    );
  }

  BoxDecoration robotDecoration(double radius) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.robotGlow, AppColors.robotDark],
      ),
      borderRadius: BorderRadius.circular(radius),
      border:
          Border.all(color: AppColors.teal.withValues(alpha: 0.45), width: 2),
    );
  }
}

class RobotArm extends StatelessWidget {
  const RobotArm({super.key, required this.left});

  final bool left;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: left ? -0.26 : 0.26,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.robotLight, AppColors.robotDark],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: AppColors.deepTeal.withValues(alpha: 0.55), width: 2),
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.robotLight,
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.deepTeal.withValues(alpha: 0.55), width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class RobotEye extends StatelessWidget {
  const RobotEye({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.coral,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.deepTeal, width: 3),
      ),
      child: Center(
        child: Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 0.74,
              colors: [Colors.white, Colors.black],
              stops: [0.14, 0.15],
            ),
          ),
        ),
      ),
    );
  }
}

class RobotEar extends StatelessWidget {
  const RobotEar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 45,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.robotLight, AppColors.robotDark],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: AppColors.deepTeal.withValues(alpha: 0.55), width: 2),
      ),
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
          color: AppColors.teal, borderRadius: BorderRadius.circular(6)),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(size * 0.18),
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            Text('+', textAlign: TextAlign.center),
            Text('×', textAlign: TextAlign.center),
            Text('−', textAlign: TextAlign.center),
            Text('=', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ScanCubeIcon extends StatelessWidget {
  const ScanCubeIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.view_in_ar_rounded,
              color: AppColors.softBlue, size: size * 0.58),
          CustomPaint(size: Size.square(size), painter: ScanCornersPainter()),
        ],
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
          color: AppColors.vietnamRed, borderRadius: BorderRadius.circular(2)),
      child: const Icon(Icons.star, color: Colors.yellow, size: 11),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > 10 ? digits.substring(0, 10) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < clipped.length; i++) {
      if (i == 3 || i == 6) buffer.write(' ');
      buffer.write(clipped[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class BookmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bookmark;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.72)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.deepTeal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height, size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.softBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final corner = size.width * 0.34;
    final inset = size.width * 0.05;

    void drawCorner(Offset a, Offset b, Offset c) {
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy);
      canvas.drawPath(path, paint);
    }

    drawCorner(Offset(inset + corner, inset), Offset(inset, inset),
        Offset(inset, inset + corner));
    drawCorner(
        Offset(size.width - inset - corner, inset),
        Offset(size.width - inset, inset),
        Offset(size.width - inset, inset + corner));
    drawCorner(
        Offset(inset, size.height - inset - corner),
        Offset(inset, size.height - inset),
        Offset(inset + corner, size.height - inset));
    drawCorner(
        Offset(size.width - inset, size.height - inset - corner),
        Offset(size.width - inset, size.height - inset),
        Offset(size.width - inset - corner, size.height - inset));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

abstract final class AppColors {
  static const ink = Color(0xFF25352E);
  static const muted = Color(0xFF53675F);
  static const teal = Color(0xFF00776F);
  static const tealLight = Color(0xFF0C9C91);
  static const aquaMist = Color(0xFFBFECEF);
  static const mintMist = Color(0xFFEFFAE8);
  static const aquaSoft = Color(0xFF79D5CF);
  static const softBlue = Color(0xFF87C7CD);
  static const softTeal = Color(0xFF85BDB7);
  static const coral = Color(0xFFFF7C5D);
  static const coralLight = Color(0xFFFF8762);
  static const peach = Color(0xFFFFD2C1);
  static const mathInk = Color(0xFF913513);
  static const bookmark = Color(0xC2C1BAA6);
  static const robotGlow = Color(0xFF92EEE2);
  static const robotLight = Color(0xFF2EC9B9);
  static const robotDark = Color(0xFF056E68);
  static const deepTeal = Color(0xFF075F5A);
  static const panelDark = Color(0xFF1F4A46);
  static const sandRing = Color(0xBFD7D3C2);
  static const grayText = Color(0xFF7B8985);
  static const inputLine = Color(0xFFDBE7DF);
  static const vietnamRed = Color(0xFFE72720);
  static const orangeAccent = Color(0xFFD46D47);
  static const timerBg = Color(0xFFF1E5DC);
  static const greenShadow = Color(0x3874B493);
}
