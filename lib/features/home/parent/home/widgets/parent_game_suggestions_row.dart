part of '../../../home_screen.dart';

class _ParentGameSuggestionsRow extends StatelessWidget {
  const _ParentGameSuggestionsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StudentGamePreviewCard(
            asset: 'assets/images/game_numi_farm_banner.png',
            background: Color(0xFFDDF3EE),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StudentGamePreviewCard(
            background: Color(0xFF111C4B),
            child: _StudentMathSquadronPreviewArtwork(),
          ),
        ),
      ],
    );
  }
}
