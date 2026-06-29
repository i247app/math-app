import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
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
              Center(
                child: Text(
                  'NUMINUMI',
                  style: GoogleFonts.andika(
                    color: const Color(0xFF339395), // Teal from image
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
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
    this.devOtpCode,
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
  final String? devOtpCode;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final otpCode = devOtpCode?.trim();

    // Check if all OTP boxes have a digit
    final isFull = controllers.every((c) => c.text.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // OTP Inputs
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = constraints.maxWidth < 290 ? 10.0 : 12.0;
            final availableBoxWidth = (constraints.maxWidth - gap * 3) / 4;
            final boxWidth = availableBoxWidth.clamp(58.0, 64.0);
            final boxHeight = boxWidth * 1.18;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
                  child: SizedBox(
                    width: boxWidth,
                    height: boxHeight,
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
        if (otpCode != null && otpCode.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              context.formatText(AppKeys.otpSentMessage, {'code': otpCode}),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: errorText == null
              ? const SizedBox(height: 16)
              : Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFD9534F),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
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
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 22,
              child: resendCountdown > 0
                  ? Text(
                      context.formatText(AppKeys.resendOtpAfter, {
                        'seconds': resendCountdown,
                      }),
                      style: GoogleFonts.andika(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF339395),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Action Button
        _TealActionButton(
          label: isVerifyingOtp
              ? context.getText(AppKeys.otpConfirming)
              : resendCountdown == 0
              ? context.getText(AppKeys.resendOtp)
              : context.getText(AppKeys.otpConfirm),
          onPressed: isVerifyingOtp
              ? null
              : resendCountdown == 0
              ? onResend
              : isFull
              ? onConfirm
              : null,
        ),
      ],
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError ? const Color(0xFFD9534F) : const Color(0xFFF47B55),
            width: 2.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF47B55).withValues(alpha: 0.22),
              blurRadius: 0,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
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
            style: GoogleFonts.andika(
              color: AppColors.ink,
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}

class _TealActionButton extends StatelessWidget {
  const _TealActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('→', '').trim();

    return Center(
      child: SizedBox(
        width: 230,
        height: 58,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF339395), // Teal from design
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            disabledBackgroundColor: const Color(
              0xFFB5BFC2,
            ), // Grey when disabled
            disabledForegroundColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    cleanLabel.toUpperCase(),
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
