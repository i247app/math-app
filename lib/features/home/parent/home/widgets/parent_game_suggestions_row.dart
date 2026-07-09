import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numi_flutter/features/home/widgets/home_game_preview_card.dart';
import 'package:numi_flutter/features/home/widgets/home_math_squadron_preview_artwork.dart';

class ParentGameSuggestionsRow extends StatelessWidget {
  const ParentGameSuggestionsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: HomeGamePreviewCard(
            asset: 'assets/images/game_numi_farm_banner.png',
            background: Color(0xFFDDF3EE),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: HomeGamePreviewCard(
            background: Color(0xFF111C4B),
            child: HomeMathSquadronPreviewArtwork(),
          ),
        ),
      ],
    );
  }
}