import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ParentTaskDateLabel extends StatelessWidget {
  const ParentTaskDateLabel({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.alarm_rounded,
          color: colors.textSecondary,
          size: FontSize.xxs,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: FontSize.xxs,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
