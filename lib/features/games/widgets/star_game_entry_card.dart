import 'package:material_ui/material_ui.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';

class StarGameEntryCard extends StatelessWidget {
  const StarGameEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            const Positioned.fill(child: StarGameBackdrop(banner: true)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xB210132F),
                      Color(0x7010132F),
                      Colors.transparent,
                    ],
                    stops: [0, .47, .76],
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 124),
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(end: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.getText(AppKeys.gamesTitle),
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.getText(AppKeys.gamesPitch),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: starGameMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xA6101839),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(7),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
