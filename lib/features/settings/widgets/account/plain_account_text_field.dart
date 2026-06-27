import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/settings_style.dart';

class PlainAccountTextField extends StatelessWidget {
  const PlainAccountTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.scale,
    this.keyboardType,
    this.textStyle,
  });

  final TextEditingController controller;
  final bool enabled;
  final double scale;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        GoogleFonts.andika(
          color: settingsDeepInk,
          fontSize: FontSize.large * scale,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        );

    return TextField(
      controller: controller,
      readOnly: !enabled,
      enableInteractiveSelection: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: style,
      decoration: const InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
