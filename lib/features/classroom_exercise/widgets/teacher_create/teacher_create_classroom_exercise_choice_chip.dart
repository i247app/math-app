import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';

class CreateClassroomExerciseChoiceChip extends StatelessWidget {
  const CreateClassroomExerciseChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final isEnabled = onTap != null;

    return Semantics(
      button: true,
      selected: selected,
      enabled: isEnabled,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 42, minWidth: 58),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? colors.brandStrong
                  : isEnabled
                  ? colors.elevatedSurface
                  : colors.disabledBackground,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? colors.brandStrong : colors.border,
              ),
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: selected
                    ? colors.onBrand
                    : isEnabled
                    ? colors.textSecondary
                    : colors.disabledForeground,
                fontSize: FontSize.small,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
