import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/font_size.dart';

class SettingsCancelButton extends StatelessWidget {
  const SettingsCancelButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD995),
      elevation: 0,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 138,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFB74419),
                size: 20,
              ),
              Text(
                context.getText(AppKeys.cancel).toUpperCase(),
                style: GoogleFonts.andika(
                  color: const Color(0xFFB74419),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
