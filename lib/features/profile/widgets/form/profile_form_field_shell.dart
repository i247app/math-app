import 'package:flutter/material.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/app_typography.dart';

import 'package:numi/core/theme/font_size.dart';
import 'package:numi/shared/layouts/app_form_field_layout.dart';

class ProfileFormFieldShell extends StatelessWidget {
  const ProfileFormFieldShell({
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
      borderColor: Theme.of(context).brightness == Brightness.dark
          ? context.themeColors.borderStrong
          : null,
      labelStyle: (context.textStyles.bodyLarge ?? const TextStyle()).copyWith(
        color: context.themeColors.textSecondary,
        fontSize: FontSize.small,
        fontWeight: FontWeight.w900,
        height: 1,
        letterSpacing: 0,
      ),
      child: child,
    );
  }
}
