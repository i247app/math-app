import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_game_preview_card.dart';
import 'package:numi/features/home/widgets/home_math_squadron_preview_artwork.dart';

class HomeGamePreviewRow extends StatelessWidget {
  const HomeGamePreviewRow({super.key, this.gap = 16, this.height = 150});

  final double gap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: gap,
      children: [
        Expanded(
          child: HomeGamePreviewCard(
            asset: 'assets/images/game-numi-farm-banner.png',
            background: const Color(0xFFDDF3EE),
            height: height,
          ),
        ),
        Expanded(
          child: HomeGamePreviewCard(
            background: const Color(0xFF111C4B),
            height: height,
            child: const HomeMathSquadronPreviewArtwork(),
          ),
        ),
      ],
    );
  }
}
