import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/widgets/otp/otp_action_button.dart';
import 'package:numi/features/auth/widgets/otp/otp_digit_box.dart';

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
    final colors = context.themeColors;
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
                  // Focus is requested by OtpScreen after the fields have
                  // registered their numeric input configuration with Android.
                  autofocus: false,
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
                color: colors.brandStrong,
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
                      Icon(
                        Icons.error_outline_rounded,
                        color: colors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            color: colors.error,
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
        const SizedBox(height: 14),
        SizedBox(
          height: 24,
          child: resendCountdown > 0
              ? _OtpCountdownText(
                  text: context.formatText(AppKeys.resendOtpAfter, {
                    'seconds': resendCountdown,
                  }),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _OtpCountdownText extends StatelessWidget {
  const _OtpCountdownText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final baseStyle = GoogleFonts.andika(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.25,
      color: colors.textPrimary,
      letterSpacing: 0,
    );
    final numberStyle = baseStyle.copyWith(
      color: colors.brandStrong,
      fontWeight: FontWeight.w800,
    );

    final spans = <TextSpan>[];
    var cursor = 0;
    for (final match in RegExp(r'\d+').allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: numberStyle,
        ),
      );
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Center(
      child: Text.rich(
        TextSpan(style: baseStyle, children: spans),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
