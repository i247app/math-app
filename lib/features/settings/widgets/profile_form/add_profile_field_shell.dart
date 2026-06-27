import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';
import 'package:numi_flutter/features/settings/widgets/common/settings_field_shell.dart';

class AddProfileFieldShell extends StatelessWidget {
  const AddProfileFieldShell({
    super.key,
    required this.label,
    required this.child,
    required this.scale,
  });

  final String label;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SettingsFieldShell(
      label: label,
      scale: scale,
      labelStyle: GoogleFonts.andika(
        color: const Color(0xFF604950),
        fontSize: FontSize.small * scale,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
      child: child,
    );
  }
}
