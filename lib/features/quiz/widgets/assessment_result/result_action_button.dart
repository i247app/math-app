import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssessmentResultActionButton extends StatelessWidget {
  const AssessmentResultActionButton({
    super.key,
    required this.label,
    required this.background,
    required this.onTap,
    this.icon,
  });

  final String label;
  final Color background;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 57,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 28 / 18,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: Colors.white, size: 18, weight: 700),
            ],
          ),
        ),
      ),
    );
  }
}
