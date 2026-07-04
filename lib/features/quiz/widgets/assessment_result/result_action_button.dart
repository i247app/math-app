import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentResultActionButton extends StatelessWidget {
  const AssessmentResultActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.scale,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final double scale;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20 * scale),
        child: Ink(
          width: 145 * scale,
          height: 57 * scale,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 2 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      letterSpacing: -0.2 * scale,
                    ),
                  ),
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: 8 * scale),
                Icon(icon, color: Colors.white, size: 18 * scale, weight: 700),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
