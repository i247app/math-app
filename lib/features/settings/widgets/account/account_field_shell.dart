import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/layouts/app_form_field_layout.dart';

class AccountFieldShell extends StatelessWidget {
  const AccountFieldShell({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppFormFieldLayout(
      label: label,
      trailing: trailing,
      labelGap: 12,
      height: 60,
      horizontalPadding: 20,
      borderRadius: 12,
      borderColor: Theme.of(context).brightness == Brightness.dark
          ? context.themeColors.borderStrong
          : const Color(0xFFCFCFCF),
      borderWidth: 1.2,
      labelStyle: GoogleFonts.andika(
        color: Theme.of(context).brightness == Brightness.dark
            ? context.themeColors.textSecondary
            : const Color(0xFF604950),
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
      child: child,
    );
  }
}
