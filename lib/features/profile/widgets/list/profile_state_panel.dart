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
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 360 * scale),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.tealIcon, size: 54 * scale),
          SizedBox(height: 18 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: AppColors.textPrimary,
              fontSize: FontSize.xxxl * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.andika(
              color: AppColors.textSubtle,
              fontSize: FontSize.small * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          if (buttonLabel != null && onTap != null) ...[
            SizedBox(height: 20 * scale),
            Material(
              color: AppColors.tealIcon,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 22 * scale,
                    vertical: 12 * scale,
                  ),
                  child: Text(
                    buttonLabel!,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: FontSize.small * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
