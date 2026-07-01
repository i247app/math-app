import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasscodeSkipButton extends StatelessWidget {
  const PasscodeSkipButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: GoogleFonts.andika(
              color: onPressed == null
                  ? const Color(0xFF001741).withValues(alpha: 0.45)
                  : const Color(0xFF001741),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 20 / 16,
              decoration: TextDecoration.underline,
              decorationColor: onPressed == null
                  ? const Color(0xFF001741).withValues(alpha: 0.45)
                  : const Color(0xFF001741),
            ),
          ),
        ),
      ),
    );
  }
}
