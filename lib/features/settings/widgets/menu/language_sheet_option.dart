import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';

class LanguageSheetOption extends StatelessWidget {
  const LanguageSheetOption({
    super.key,
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return Material(
      color: selected ? const Color(0xFFFFF2F8) : const Color(0xFFF7FBFB),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? const Color(0xFFC1277D)
                  : const Color(0xFFDCE6E3),
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: FontSize.xxxl),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: AppColors.textPrimary,
                    fontSize: FontSize.normal,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFC1277D) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC1277D), width: 2),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
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
