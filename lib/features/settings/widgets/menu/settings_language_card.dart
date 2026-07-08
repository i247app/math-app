import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/localization/app_language.dart';
import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/widgets/menu/language_bottom_sheet.dart';
import 'package:numi_flutter/features/settings/widgets/menu/language_pill.dart';

class SettingsLanguageCard extends StatelessWidget {
  const SettingsLanguageCard({
    super.key,
    required this.currentLanguage,
    required this.scale,
    required this.onLanguageChanged,
  });

  final AppLanguage currentLanguage;
  final double scale;
  final ValueChanged<AppLanguage> onLanguageChanged;

  Future<void> _showLanguageSheet(BuildContext context) async {
    HapticFeedback.selectionClick();
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return LanguageBottomSheet(
          currentLanguage: currentLanguage,
          scale: scale,
        );
      },
    );

    if (selected == null || selected == currentLanguage) {
      return;
    }
    onLanguageChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: radius,
      child: InkWell(
        onTap: () => _showLanguageSheet(context),
        borderRadius: radius,
        child: Container(
          height: 72 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF3F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language_rounded,
                  color: const Color(0xFF5B7AA0),
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Text(
                  context.getText(AppKeys.language),
                  style: GoogleFonts.andika(
                    color: AppColors.textPrimary,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              LanguagePill(currentLanguage: currentLanguage, scale: scale),
            ],
          ),
        ),
      ),
    );
  }
}
