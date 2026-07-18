import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';

class SettingsSaveButton extends StatelessWidget {
  const SettingsSaveButton({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled
        ? AppColors.tealIcon
        : const Color(0xFFBFC9CA);
    final foregroundColor = enabled ? Colors.white : const Color(0xFFF4F6F6);

    return Material(
      color: backgroundColor,
      elevation: enabled ? 9 : 0,
      shadowColor: Colors.black.withValues(alpha: enabled ? 0.30 : 0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 142,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                context.getText(AppKeys.save),
                style: GoogleFonts.andika(
                  color: foregroundColor,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: foregroundColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
