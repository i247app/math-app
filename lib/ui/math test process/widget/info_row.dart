import 'package:flutter/material.dart';

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
            const Text(
              "9:15",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Text(
          "Câu 3/20",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
