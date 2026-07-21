import 'package:flutter/material.dart';

import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class TeacherSelectedChip extends StatelessWidget {
  const TeacherSelectedChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFAD7BE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFC4C6D2).withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 118),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textInkDark,
                fontSize: FontSize.caption,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
          InkWell(
            onTap: onDeleted,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textInkDark.withValues(alpha: 0.45),
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
