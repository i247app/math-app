import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/settings/widgets/common/settings_field_shell.dart';

class AccountFieldShell extends StatelessWidget {
  const AccountFieldShell({
    super.key,
    required this.label,
    required this.child,
    required this.scale,
    this.trailing,
  });

  final String label;
  final Widget child;
  final double scale;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SettingsFieldShell(
      label: label,
      scale: scale,
      trailing: trailing,
      labelGap: 12,
      height: 60,
      horizontalPadding: 20,
      borderRadius: 12,
      borderColor: const Color(0xFFCFCFCF),
      borderWidth: 1.2,
      labelStyle: GoogleFonts.andika(
        color: const Color(0xFF604950),
        fontSize: FontSize.normal * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
      child: child,
    );
  }
}
