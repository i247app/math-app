import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/menu/language_bottom_sheet.dart';
import 'package:numi/features/settings/widgets/menu/language_pill.dart';

class SettingsLanguageCard extends StatelessWidget {
  const SettingsLanguageCard({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  Future<void> _showLanguageSheet(BuildContext context) async {
    HapticFeedback.selectionClick();
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return LanguageBottomSheet(currentLanguage: currentLanguage);
      },
    );

    if (selected == null || selected == currentLanguage) {
      return;
    }
    onLanguageChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final radius = BorderRadius.circular(16);

    return Material(
      color: colors.elevatedSurface,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _showLanguageSheet(context),
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.elevatedSurface,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: colors.brandStrong,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.getText(AppKeys.language),
                  style: GoogleFonts.andika(
                    color: colors.textPrimary,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              LanguagePill(currentLanguage: currentLanguage),
            ],
          ),
        ),
      ),
    );
  }
}
