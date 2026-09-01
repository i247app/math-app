import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';

class StudentJoinGradeChip extends StatelessWidget {
  const StudentJoinGradeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 66,
            minHeight: 30,
            maxHeight: 30,
          ),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.teal520 : const Color(0xFFE0E3E6),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textMuted,
                        fontSize: FontSize.small,
                        fontWeight: FontWeight.w700,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
                if (selected)
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
