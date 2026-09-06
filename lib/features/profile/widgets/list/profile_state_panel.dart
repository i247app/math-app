import 'package:numi/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/theme/font_size.dart';

class ProfileStatePanel extends StatelessWidget {
  const ProfileStatePanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Icon(icon, color: AppColors.tealIcon, size: 54),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: AppColors.textPrimary,
              fontSize: FontSize.xxxl,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.andika(
                color: AppColors.textSubtle,
                fontSize: FontSize.small,
                fontWeight: FontWeight.w700,
                height: 1.35,
                letterSpacing: 0,
              ),
            ),
          ),
          if (buttonLabel != null && onTap != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Material(
                color: AppColors.tealIcon,
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    child: Text(
                      buttonLabel!,
                      style: GoogleFonts.andika(
                        color: Colors.white,
                        fontSize: FontSize.small,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
