import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/home/parent/shared/widgets/parent_task_icon_box.dart';

class ParentEmptyTaskLine extends StatelessWidget {
  const ParentEmptyTaskLine({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Row(
      children: [
        ParentTaskIconBox(
          icon: icon,
          color: colors.brandStrong,
          backgroundColor: colors.infoSurface,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: FontSize.small,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
