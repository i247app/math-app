import 'package:flutter/material.dart';
import 'package:numi/features/home/widgets/home_game_preview_row.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

class ParentGameSuggestionsRow extends StatelessWidget {
  const ParentGameSuggestionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeGamePreviewRow(
      gap: 12,
      height: parentHomePromoActionHeight,
    );
  }
}
