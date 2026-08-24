import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/theme/app_radius.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key, required this.currentLanguage});

  final AppLanguage currentLanguage;

  static String _flagFor(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.vi => '🇻🇳',
      AppLanguage.en => '🇬🇧',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: colors.brandStrong, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Text(
            _flagFor(currentLanguage),
            style: const TextStyle(fontSize: FontSize.small),
          ),
          Text(
            currentLanguage.displayName,
            style: GoogleFonts.andika(
              fontSize: FontSize.caption,
              fontWeight: FontWeight.w700,
              color: colors.brandStrong,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
