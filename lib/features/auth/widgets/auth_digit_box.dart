import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

enum _AuthDigitBoxVariant { otp, passcode }

class AuthDigitBox extends StatelessWidget {
  const AuthDigitBox.otp({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.textInputAction,
    required this.onChanged,
    required this.onEmptyBackspace,
    required this.hasError,
  }) : _variant = _AuthDigitBoxVariant.otp;

  const AuthDigitBox.passcode({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.textInputAction,
    required this.onChanged,
    required this.onEmptyBackspace,
    required this.hasError,
  }) : _variant = _AuthDigitBoxVariant.passcode;

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final VoidCallback onEmptyBackspace;
  final bool hasError;
  final _AuthDigitBoxVariant _variant;

  bool get _isPasscode => _variant == _AuthDigitBoxVariant.passcode;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final field = Center(
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
        obscureText: _isPasscode,
        obscuringCharacter: '•',
        maxLength: _isPasscode ? 1 : null,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        onTap: () {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: colors.textPrimary,
          fontSize: _isPasscode
              ? FontSize.displayMedium
              : FontSize.displayLarge,
          fontWeight: _isPasscode ? FontWeight.w700 : FontWeight.w600,
          height: _isPasscode ? 1 : null,
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
    );

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
          borderRadius: BorderRadius.circular(_isPasscode ? 16 : 14),
          border: Border.all(
            color: hasError
                ? colors.error
                : _isPasscode
                ? colors.passcodeBorder
                : colors.otpBorder,
            width: _isPasscode ? 3 : 2.3,
          ),
          boxShadow: _isPasscode
              ? [
                  BoxShadow(
                    color: colors.passcodeShadow,
                    blurRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
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
        child: _isPasscode
            ? Material(type: MaterialType.transparency, child: field)
            : field,
      ),
    );
  }
}
