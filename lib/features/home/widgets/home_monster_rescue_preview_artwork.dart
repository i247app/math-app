import 'package:flutter/material.dart';

class HomeMonsterRescuePreviewArtwork extends StatelessWidget {
  const HomeMonsterRescuePreviewArtwork({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/game-numi-electric-rescue.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x99103737)],
              stops: [0.55, 1],
            ),
          ),
        ),
        const Positioned(
          left: 10,
          bottom: 9,
          child: Row(
            children: [
              Icon(Icons.lock_open_rounded, color: Color(0xFFFFD84D), size: 18),
              SizedBox(width: 4),
              Text(
                'RESCUE!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
