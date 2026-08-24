import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_spacing.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
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
    final colors = context.themeColors;
    final backgroundColor = enabled
        ? colors.brandStrong
        : colors.disabledBackground;
    final foregroundColor = enabled
        ? colors.onBrand
        : colors.disabledForeground;

    return Material(
      color: backgroundColor,
      elevation: enabled ? 9 : 0,
      shadowColor: colors.shadow.withValues(alpha: enabled ? 0.30 : 0),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: SizedBox(
          width: 142,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: AppSpacing.s10,
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
