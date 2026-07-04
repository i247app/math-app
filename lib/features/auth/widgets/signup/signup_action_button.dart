import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupActionButton extends StatelessWidget {
  const SignupActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('→', '').trim();

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF078B83),
          foregroundColor: Colors.white,
          elevation: onPressed == null ? 0 : 10,
          shadowColor: const Color(0xFF078B83).withValues(alpha: 0.22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          disabledBackgroundColor: const Color(0xFFB5BFC2),
          disabledForegroundColor: Colors.white,
        ),
        child: Text(
          cleanLabel,
          textAlign: TextAlign.center,
          style: GoogleFonts.andika(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
