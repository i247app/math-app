part of '../../../home_screen.dart';

class _StudentGameSuggestionsSection extends StatelessWidget {
  const _StudentGameSuggestionsSection({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: Color(0xFF2D7BEA),
                size: 18,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                context.getText(AppKeys.navGames),
                style: const TextStyle(
                  color: Color(0xFF202328),
                  fontSize: FontSize.normal,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.getText(AppKeys.viewAll)),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: HomeGamePreviewCard(
                asset: 'assets/images/game_numi_farm_banner.png',
                background: Color(0xFFDDF3EE),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: HomeGamePreviewCard(
                background: Color(0xFF111C4B),
                child: HomeMathSquadronPreviewArtwork(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
