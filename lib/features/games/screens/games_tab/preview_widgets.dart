part of '../games_tab.dart';

class _GamePreviewCard extends StatelessWidget {
  const _GamePreviewCard({required this.game, required this.onTap});

  final _GamePreview game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final background = Theme.of(context).brightness == Brightness.dark
        ? colors.elevatedSurface
        : game.background;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          constraints: const BoxConstraints(minHeight: 158),
          padding: const EdgeInsets.fromLTRB(20, 20, 14, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: game.accent.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.74),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context.getText(AppKeys.gamesPrototype),
                        style: TextStyle(
                          color: game.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.formatText(AppKeys.gamesLevelCount, {
                        'count': game.levelCount,
                      }),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 104,
                height: 112,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(game.assetPath, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamesMessageCard extends StatelessWidget {
  const _GamesMessageCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.infoSurface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.info, size: 34),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _GamePreview {
  const _GamePreview({
    required this.id,
    required this.title,
    required this.assetPath,
    required this.background,
    required this.accent,
    this.levelCount = 5,
    this.levelTitleKeys,
  });

  final String id;
  final String title;
  final String assetPath;
  final Color background;
  final Color accent;
  final int levelCount;
  final List<String>? levelTitleKeys;
}

List<_GamePreview> _gamePreviews(BuildContext context) {
  return [
    _GamePreview(
      id: 'journey-1',
      title: context.getText(AppKeys.gamesJourneyOne),
      assetPath: 'assets/images/game-numi-farm-banner.png',
      background: const Color(0xFFDDF3EE),
      accent: _gamesTeal,
    ),
    _GamePreview(
      id: 'monster-rescue',
      title: context.getText(AppKeys.gamesRescueTitle),
      assetPath: 'assets/images/game-numi-electric-rescue.png',
      background: const Color(0xFFDDF6E7),
      accent: const Color(0xFF007D77),
      levelCount: monsterRescueLevels.length,
      levelTitleKeys: monsterRescueLevels
          .map((level) => level.titleKey)
          .toList(growable: false),
    ),
  ];
}
