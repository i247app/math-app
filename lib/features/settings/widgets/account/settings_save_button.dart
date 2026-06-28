import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/settings_style.dart';

class SettingsSaveButton extends StatelessWidget {
  const SettingsSaveButton({
    super.key,
    required this.scale,
    required this.onTap,
    this.enabled = true,
  });

  final double scale;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = enabled ? settingsTeal : const Color(0xFFBFC9CA);
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
          width: 142 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.getText(AppKeys.save),
                style: GoogleFonts.andika(
                  color: foregroundColor,
                  fontSize: FontSize.large * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: foregroundColor,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
