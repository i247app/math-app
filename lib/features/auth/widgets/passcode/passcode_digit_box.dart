import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/app_colors.dart';

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? const Color(0xFFD9534F) : const Color(0xFF6E7474),
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDCBFC8),
              blurRadius: 0,
              offset: Offset(0, 4),
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
              color: AppColors.ink,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1,
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
