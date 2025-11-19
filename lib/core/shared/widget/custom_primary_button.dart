import 'package:flutter/material.dart';
  import 'package:google_fonts/google_fonts.dart';

  class CustomPrimaryButton extends StatelessWidget {
    final String text;
    final VoidCallback? onPressed;
    final Color? backgroundColor;
    final Color? textColor;
    final double? width;
    final double height;

    const CustomPrimaryButton({
      super.key,
      required this.text,
      required this.onPressed,
      this.backgroundColor,
      this.textColor,
      this.width = double.infinity,
      this.height = 56.0,
    });

    @override
    Widget build(BuildContext context) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? const Color(0xFF4C3D3D),
            elevation: onPressed != null ? 5 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor ?? Colors.white,
            ),
          ),
        ),
      );
    }
  }