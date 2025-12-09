import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class QuestionBoard extends StatelessWidget {
  final String question;

  const QuestionBoard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF48C8B5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF9E498), width: 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.2).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: AutoSizeText(
          question,
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.visible,
          minFontSize: 20,
          maxFontSize: 30,
          style: GoogleFonts.nunito(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
