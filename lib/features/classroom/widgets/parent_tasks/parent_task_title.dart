import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class ParentTaskTitle extends StatelessWidget {
  const ParentTaskTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colors.textPrimary,
        fontSize: FontSize.normal,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
    );
  }
}
