import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class PasscodeDigitBox extends StatelessWidget {
  const PasscodeDigitBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.textInputAction,
    required this.hasError,
    required this.onChanged,
    required this.onEmptyBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmptyBackspace;

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? colors.error : colors.passcodeBorder,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.passcodeShadow,
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
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
              obscureText: true,
              obscuringCharacter: '•',
              maxLength: 1,
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
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1,
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
      ),
    );
  }
}
