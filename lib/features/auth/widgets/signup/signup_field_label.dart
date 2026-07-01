import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupFieldLabel extends StatelessWidget {
  const SignupFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.andika(
          color: const Color(0xFF1B1B1B),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE74657)),
            ),
        ],
      ),
    );
  }
}
