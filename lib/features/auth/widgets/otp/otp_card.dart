import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/features/auth/widgets/otp/otp_action_button.dart';
import 'package:numi_flutter/features/auth/widgets/otp/otp_digit_box.dart';

class OtpCard extends StatelessWidget {
  const OtpCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.autoFocusCode,
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
  final bool autoFocusCode;
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
    final isFull = controllers.every(
      (controller) => controller.text.isNotEmpty,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
              child: SizedBox(
                width: 64,
                height: 70,
                child: OtpDigitBox(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  autofocus: autoFocusCode && index == 0,
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
        OtpActionButton(
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
