import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/layouts/app_form_field_layout.dart';

class AddProfileFieldShell extends StatelessWidget {
  const AddProfileFieldShell({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppFormFieldLayout(
      label: label,
      labelStyle: GoogleFonts.andika(
        color: const Color(0xFF604950),
        fontSize: FontSize.small,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
      child: child,
    );
  }
}
