import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class SignupFieldLabel extends StatelessWidget {
  const SignupFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: colors.textPrimary,
          fontSize: FontSize.normal,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(color: colors.error),
            ),
        ],
      ),
    );
  }
}
