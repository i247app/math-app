import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/menu/language_sheet_option.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key, required this.currentLanguage});

  final AppLanguage currentLanguage;

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
        padding: EdgeInsets.fromLTRB(16, 0, 16, math.max(14, bottomInset + 10)),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8E2E0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        context.getText(AppKeys.languageTitle),
                        style: GoogleFonts.andika(
                          color: AppColors.textPrimary,
                          fontSize: FontSize.large,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Column(
                        spacing: 10,
                        children: [
                          for (final language in AppLanguage.values)
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
                              onTap: () => Navigator.of(context).pop(language),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
