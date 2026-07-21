import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:numi/core/theme/app_theme_colors.dart';

class TeacherClassDetailCodeChip extends StatelessWidget {
  const TeacherClassDetailCodeChip({
    super.key,
    required this.code,
    required this.onCopy,
  });
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      height: 27,
      constraints: const BoxConstraints(minWidth: 114, maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                code,
                maxLines: 1,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: FontSize.compact,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: SvgPicture.asset(
                'assets/images/teacher_class_link_copy.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
