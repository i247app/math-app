import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/theme/app_theme_colors.dart';

class CreateHomeworkSelectField extends StatelessWidget {
  const CreateHomeworkSelectField({
    super.key,
    required this.onTap,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    this.valueKey,
    this.valueText,
    this.radius = 8,
    this.borderColor = const Color(0xFFDDE4E6),
    this.borderWidth = 2,
  });

  final String? valueKey;
  final String? valueText;
  final VoidCallback onTap;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final text = valueText ?? context.getText(valueKey!);
    return Material(
      color: colors.inputSurface,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          decoration: BoxDecoration(
            color: colors.inputSurface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor == const Color(0xFFDDE4E6)
                  ? colors.border
                  : borderColor,
              width: borderWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: colors.textPrimary.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SvgPicture.asset(iconAsset, width: iconWidth, height: iconHeight),
            ],
          ),
        ),
      ),
    );
  }
}
