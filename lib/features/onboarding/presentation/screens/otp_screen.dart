import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import '../widgets/login_scene_background.dart';
import '../widgets/numi_brand_mascot.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.onBack,
    required this.onConfirm,
    required this.onResend,
    required this.isVerifyingOtp,
    required this.resendSeconds,
    required this.resendResetId,
    this.otpError,
    this.otpErrorId = 0,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onConfirm;
  final VoidCallback onResend;
  final bool isVerifyingOtp;
  final int resendSeconds;
  final int resendResetId;
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
      controllers[nextIndex].selection =
          const TextSelection.collapsed(offset: 1);
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
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onConfirm(otpCode);
  }

  void handleResend() {
    if (resendCountdown > 0) {
      HapticFeedback.selectionClick();
      return;
    }

    widget.onResend();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final mascotSize = width < 370 ? 230.0 : 260.0;
    final otpError = hideOtpError ? null : widget.otpError;

    return Stack(
      children: [
        const Positioned.fill(child: LoginSceneBackground()),
        ScreenFrame(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: widget.onBack,
                  ),
                  const Spacer(),
                  const ProgressDots(activeIndex: 2),
                ],
              ),
              SizedBox(height: compact ? 34 : 54),
              Center(
                child: NumiBrandMascot(size: mascotSize),
              ),
              SizedBox(height: compact ? 10 : 18),
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
                child: OtpCard(
                  controllers: controllers,
                  focusNodes: focusNodes,
                  onChanged: updateDigit,
                  onEmptyBackspace: handleEmptyBackspace,
                  onConfirm: handleConfirm,
                  onResend: handleResend,
                  isVerifyingOtp: widget.isVerifyingOtp,
                  resendCountdown: resendCountdown,
                  errorText: otpError,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class OtpCard extends StatelessWidget {
  const OtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.onEmptyBackspace,
    required this.onConfirm,
    required this.onResend,
    required this.isVerifyingOtp,
    required this.resendCountdown,
    this.errorText,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final ValueChanged<int> onEmptyBackspace;
  final VoidCallback onConfirm;
  final VoidCallback onResend;
  final bool isVerifyingOtp;
  final int resendCountdown;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 20.0 : 30.0;
    final hasError = errorText != null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        32,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            blurRadius: 22,
            offset: Offset(0, 14),
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
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = constraints.maxWidth < 290 ? 9.0 : 12.0;
              final boxWidth = (constraints.maxWidth - gap * 3) / 4;

              return Row(
                children: List.generate(4, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
                    child: SizedBox(
                      width: boxWidth.clamp(46, 58),
                      child: OtpDigitBox(
                        controller: controllers[index],
                        focusNode: focusNodes[index],
                        autofocus: index == 0,
                        textInputAction: index == 3
                            ? TextInputAction.done
                            : TextInputAction.next,
                        onChanged: (value) => onChanged(index, value),
                        onEmptyBackspace: () => onEmptyBackspace(index),
                        hasError: hasError,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: errorText == null
                ? const SizedBox(height: 26)
                : Padding(
                    padding:
                        const EdgeInsets.only(top: 12, bottom: 14, left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFD9534F),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                              color: Color(0xFFD9534F),
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          PrimaryButton(
            label: isVerifyingOtp ? 'Đang xác thực...' : 'Xác nhận  →',
            onPressed: isVerifyingOtp ? null : onConfirm,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: resendCountdown == 0 ? onResend : null,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                resendCountdown == 0
                    ? 'Gửi lại mã'
                    : 'Gửi lại mã sau $resendCountdown giây',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
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
    required this.autofocus,
    required this.textInputAction,
    required this.onChanged,
    required this.onEmptyBackspace,
    required this.hasError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmptyBackspace;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onEmptyBackspace();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: textInputAction,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.82),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? const Color(0xFFD9534F) : AppColors.inputLine,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? const Color(0xFFD9534F) : AppColors.inputLine,
              width: hasError ? 1.6 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? const Color(0xFFD9534F) : AppColors.teal,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
