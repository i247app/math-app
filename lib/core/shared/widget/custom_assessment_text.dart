import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom text widget matching the CSS properties:
/// - font-family: Nunito
/// - font-weight: 800
/// - font-size: 25px
/// - line-height: 130%
/// - letter-spacing: 0%
/// - text-align: center
class CustomAssessmentText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomAssessmentText({
    super.key,
    required this.text,
    this.color,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.nunito(
        fontWeight: FontWeight.w800,
        fontSize: 25,
        height: 1.3,
        letterSpacing: 0.0,
        color: color ?? Colors.black,
      ),
    );
  }
}

/// Alternative: Extension method for TextStyle
extension AssessmentTextStyle on TextStyle {
  static TextStyle custom({
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w800,
    double fontSize = 25,
    double height = 1.3,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.nunito(
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
