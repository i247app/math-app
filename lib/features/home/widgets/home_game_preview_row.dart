import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_game_preview_card.dart';
import 'package:numi/features/home/widgets/home_math_squadron_preview_artwork.dart';

class HomeGamePreviewRow extends StatelessWidget {
  const HomeGamePreviewRow({super.key, this.gap = 16});

  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: HomeGamePreviewCard(
            asset: 'assets/images/game_numi_farm_banner.png',
            background: Color(0xFFDDF3EE),
          ),
        ),
        SizedBox(width: gap),
        const Expanded(
          child: HomeGamePreviewCard(
            background: Color(0xFF111C4B),
            child: HomeMathSquadronPreviewArtwork(),
          ),
        ),
      ],
    );
  }
}
