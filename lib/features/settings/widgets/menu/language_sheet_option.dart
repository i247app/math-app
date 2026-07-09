import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/theme/font_size.dart';

class LanguageSheetOption extends StatelessWidget {
  const LanguageSheetOption({
    super.key,
    required this.flag,
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18 * scale);

    return Material(
      color: selected ? const Color(0xFFFFF2F8) : const Color(0xFFF7FBFB),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? const Color(0xFFC1277D)
                  : const Color(0xFFDCE6E3),
              width: selected ? 2 * scale : 1.2 * scale,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: TextStyle(fontSize: FontSize.xxxl * scale)),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: AppColors.textPrimary,
                    fontSize: FontSize.normal * scale,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Container(
                width: 30 * scale,
                height: 30 * scale,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFC1277D) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC1277D),
                    width: 2 * scale,
                  ),
                ),
                child: selected
                    ? Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20 * scale,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
