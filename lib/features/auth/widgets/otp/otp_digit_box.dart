import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

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
    final colors = context.themeColors;

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
          color: colors.inputSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError ? colors.error : colors.otpBorder,
            width: 2.3,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.otpBorder.withValues(alpha: 0.22),
              blurRadius: 0,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
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
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
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
              color: colors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
