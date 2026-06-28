import 'package:flutter/material.dart';

class HomeMathSquadronLaser extends StatelessWidget {
  const HomeMathSquadronLaser({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 25,
      decoration: BoxDecoration(
        color: const Color(0xFF61DAFF),
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(color: Color(0xFF61DAFF), blurRadius: 9),
        ],
      ),
    );
  }
}
