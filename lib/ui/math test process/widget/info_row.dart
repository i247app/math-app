import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/imgs/alarm_clock.png',
              width: 28,
              height: 28,
              errorBuilder: (c, o, s) => const Icon(
                Icons.access_time_filled,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              "9:15",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          "Câu 3/20",
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
