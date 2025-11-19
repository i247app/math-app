import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelChartSection extends StatelessWidget {
  const LevelChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(height: 20, color: Colors.deepPurple.shade200),
              const SizedBox(width: 8),
              _buildBar(height: 35, color: Colors.orange.shade300),
              const SizedBox(width: 8),
              _buildBar(height: 50, color: Colors.teal.shade300),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  Container(
                    width: 20,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade100,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Bạn đang ở",
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0D47A1),
          ),
        ),
        Text(
          "Level 2 - Trung Bình",
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0D47A1),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
