import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_controller.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class SettingsThemeSwitchCard extends StatelessWidget {
  const SettingsThemeSwitchCard({
    super.key,
    required this.controller,
    required this.scale,
  });

  final AppThemeController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(16 * scale);
    final isDarkMode = controller.isDarkMode;

    return Material(
      color: colors.elevatedSurface,
      elevation: 0,
      borderRadius: radius,
      child: Container(
        height: 72 * scale,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.06),
              blurRadius: 10 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42 * scale,
              height: 42 * scale,
              decoration: BoxDecoration(
                color: colors.brand.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: colors.brandStrong,
                size: 22 * scale,
              ),
            ),
            SizedBox(width: 14 * scale),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.getText(AppKeys.appThemeMenuTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: colors.textPrimary,
                      fontSize: FontSize.normal * scale,
                      fontWeight: FontWeight.w700,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 5 * scale),
                  Text(
                    context.getText(_subtitleKey(controller.themeMode)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.andika(
                      color: colors.textMuted,
                      fontSize: FontSize.caption * scale,
                      fontWeight: FontWeight.w400,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: (0.82 * scale).clamp(0.72, 0.92),
              child: Switch.adaptive(
                value: isDarkMode,
                activeThumbColor: colors.brandStrong,
                activeTrackColor: colors.brandStrong.withValues(alpha: 0.34),
                onChanged: (enabled) {
                  HapticFeedback.selectionClick();
                  controller.setDarkMode(enabled);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitleKey(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => AppKeys.appThemeMenuSubtitleSystem,
      ThemeMode.light => AppKeys.appThemeMenuSubtitleLight,
      ThemeMode.dark => AppKeys.appThemeMenuSubtitleDark,
    };
  }
}
