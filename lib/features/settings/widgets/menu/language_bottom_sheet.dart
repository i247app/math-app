import 'package:numi_flutter/core/theme/app_colors.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_language.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/widgets/menu/language_sheet_option.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({
    super.key,
    required this.currentLanguage,
    required this.scale,
  });

  final AppLanguage currentLanguage;
  final double scale;

  static String _flagFor(AppLanguage lang) {
    return switch (lang) {
      AppLanguage.vi => '🇻🇳',
      AppLanguage.en => '🇬🇧',
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16 * scale,
          0,
          16 * scale,
          math.max(14 * scale, bottomInset + 10 * scale),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24 * scale,
                offset: Offset(0, 12 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              18 * scale,
              12 * scale,
              18 * scale,
              18 * scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42 * scale,
                  height: 5 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E2E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: 18 * scale),
                Text(
                  context.getText(AppKeys.languageTitle),
                  style: GoogleFonts.andika(
                    color: AppColors.textPrimary,
                    fontSize: FontSize.large * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 18 * scale),
                for (final language in AppLanguage.values) ...[
                  LanguageSheetOption(
                    flag: _flagFor(language),
                    label: switch (language) {
                      AppLanguage.vi => context.getText(
                        AppKeys.languageVietnamese,
                      ),
                      AppLanguage.en => context.getText(
                        AppKeys.languageEnglish,
                      ),
                    },
                    selected: language == currentLanguage,
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(language),
                  ),
                  if (language != AppLanguage.values.last)
                    SizedBox(height: 10 * scale),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
