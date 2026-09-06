import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class StudentClassEmptyPanel extends StatelessWidget {
  const StudentClassEmptyPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: FontSize.small,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
        ),
      ),
    );
  }
}
