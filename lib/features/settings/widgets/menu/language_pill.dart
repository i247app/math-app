import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/localization/app_language.dart';
import 'package:numi_flutter/core/theme/font_size.dart';

class LanguagePill extends StatelessWidget {
  const LanguagePill({
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 7 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: const Color(0xFF006762),
          width: 1.5 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _flagFor(currentLanguage),
            style: TextStyle(fontSize: FontSize.small * scale),
          ),
          SizedBox(width: 5 * scale),
          Text(
            currentLanguage.displayName,
            style: GoogleFonts.andika(
              fontSize: FontSize.caption * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF006762),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
