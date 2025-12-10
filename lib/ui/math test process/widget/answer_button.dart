import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AnswerButton extends StatelessWidget {
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.value,
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 111,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 5,
              bottom: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withAlpha((255 * 0.7).toInt())
                      : color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.black12,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.1).toInt()),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AutoSizeText(
                    value,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 10,
                    maxFontSize: 30,
                    style: GoogleFonts.nunito(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF5F5F5),
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
