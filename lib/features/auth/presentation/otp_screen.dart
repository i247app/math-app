import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi_flutter/features/auth/widgets/otp/otp_card.dart';
import 'package:numi_flutter/features/welcome/widgets/numi_brand_text.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.onBack,
    required this.onConfirm,
    required this.onResend,
    required this.isVerifyingOtp,
    required this.resendSeconds,
    required this.resendResetId,
    this.autoFocusCode = false,
    this.devOtpCode,
    this.otpError,
    this.otpErrorId = 0,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onConfirm;
  final VoidCallback onResend;
  final bool isVerifyingOtp;
  final int resendSeconds;
  final int resendResetId;
  final bool autoFocusCode;
  final String? devOtpCode;
  final String? otpError;
  final int otpErrorId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  static const otpLength = 4;

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;
  late final AnimationController errorShakeController;
  Timer? resendTimer;
  int resendCountdown = 0;
  bool hideOtpError = false;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(otpLength, (_) => TextEditingController());
    focusNodes = List.generate(otpLength, (_) => FocusNode());
    errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    startResendCountdown(widget.resendSeconds, notify: false);
    if (widget.autoFocusCode) {
      requestOtpFocus();
    }
  }

  @override
  void didUpdateWidget(covariant OtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resendResetId != oldWidget.resendResetId ||
        widget.resendSeconds != oldWidget.resendSeconds) {
      startResendCountdown(widget.resendSeconds);
    }

    if (widget.otpErrorId != oldWidget.otpErrorId && widget.otpError != null) {
      showOtpError();
      return;
    }

    if (widget.otpError == null && oldWidget.otpError != null) {
      hideOtpError = false;
    }

    if (widget.autoFocusCode && !oldWidget.autoFocusCode) {
      requestOtpFocus();
    }
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    errorShakeController.dispose();
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startResendCountdown(int seconds, {bool notify = true}) {
    resendTimer?.cancel();
    final initialSeconds = seconds < 0 ? 0 : seconds;
    if (notify) {
      setState(() {
        resendCountdown = initialSeconds;
      });
    } else {
      resendCountdown = initialSeconds;
    }

    if (initialSeconds == 0) {
      return;
    }

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (resendCountdown <= 1) {
        timer.cancel();
        setState(() {
          resendCountdown = 0;
        });
        return;
      }

      setState(() {
        resendCountdown--;
      });
    });
  }

  void showOtpError() {
    HapticFeedback.mediumImpact();
    for (final controller in controllers) {
      controller.clear();
    }
    setState(() {
      hideOtpError = false;
    });
    errorShakeController.forward(from: 0);
    requestOtpFocus();
  }

  void requestOtpFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        focusNodes.first.requestFocus();
      }
    });
  }

  void updateDigit(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      controllers[index].clear();
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    if (widget.otpError != null && !hideOtpError) {
      hideOtpError = true;
    }

    var nextIndex = index;
    for (final digit in digits.split('')) {
      if (nextIndex >= controllers.length) {
        break;
      }

      controllers[nextIndex].text = digit;
      controllers[nextIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      nextIndex++;
    }

    if (nextIndex < focusNodes.length) {
      focusNodes[nextIndex].requestFocus();
    } else {
      focusNodes.last.unfocus();
    }

    setState(() {});
  }

  void handleEmptyBackspace(int index) {
    if (index == 0) {
      return;
    }

    controllers[index - 1].clear();
    focusNodes[index - 1].requestFocus();
    setState(() {});
  }

  void handleConfirm() {
    final otpCode = controllers.map((controller) => controller.text).join();
    if (otpCode.length < controllers.length) {
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onConfirm(otpCode);
  }

  void handleResend() {
    if (resendCountdown > 0) {
      return;
    }

    widget.onResend();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final mascotSize = width < 370 ? 132.0 : 156.0;
    final otpError = hideOtpError ? null : widget.otpError;

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
              const SizedBox(height: 28),
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: widget.onBack,
              ),
              SizedBox(height: compact ? 20 : 36),
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
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/numi-mascot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: compact ? 14 : 20),
              // Title
              const Center(child: NumiBrandText(fontSize: 40)),
              SizedBox(height: compact ? 34 : 54),
              // OTP Card
              AnimatedBuilder(
                animation: errorShakeController,
                builder: (context, child) {
                  final offset =
                      math.sin(errorShakeController.value * math.pi * 6) *
                      9 *
                      (1 - errorShakeController.value);
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OtpCard(
                    controllers: controllers,
                    focusNodes: focusNodes,
                    autoFocusCode: widget.autoFocusCode,
                    onChanged: updateDigit,
                    onEmptyBackspace: handleEmptyBackspace,
                    onConfirm: handleConfirm,
                    onResend: handleResend,
                    isVerifyingOtp: widget.isVerifyingOtp,
                    resendCountdown: resendCountdown,
                    devOtpCode: widget.devOtpCode,
                    errorText: otpError,
                  ),
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
