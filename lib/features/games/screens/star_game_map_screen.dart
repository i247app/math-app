import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/controllers/star_game_progress.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:numi/features/games/screens/star_game_screen.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';
import 'package:numi/features/games/widgets/star_game_controls.dart';

class StarGameMapScreen extends StatefulWidget {
  const StarGameMapScreen({super.key, required this.progress});

  final StarGameProgress progress;

  @override
  State<StarGameMapScreen> createState() => _StarGameMapScreenState();
}

class _StarGameMapScreenState extends State<StarGameMapScreen> {
  StarGameProgress get _progress => widget.progress;
  bool _opening = false;

  Future<void> _play(StarGameLevel level) async {
    if (_opening || _progress.loading || !_progress.isUnlocked(level)) return;
    _opening = true;
    HapticFeedback.selectionClick();
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              StarGameScreen(initialLevel: level, progress: _progress),
        ),
      );
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: starGameInk,
    body: StarGameSky(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: BackButton(color: Colors.white),
              ),
            ),
            Expanded(child: _buildMap()),
          ],
        ),
      ),
    ),
  );

  Widget _buildMap() => ListenableBuilder(
    listenable: _progress,
    builder: (context, _) {
      final unlocked = StarGameLevel.values.where(_progress.isUnlocked);
      final next = unlocked.lastWhere(
        (level) => (_progress.best(level)?.stars ?? 0) == 0,
        orElse: () => unlocked.last,
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GameHero(
                  next: next,
                  loading: _progress.loading,
                  onPlay: () => _play(next),
                ),
                const SizedBox(height: 26),
                Text(
                  context.getText(AppKeys.gamesMap),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  context.formatText(AppKeys.gamesUnlocked, {
                    'count': unlocked.length,
                    'total': StarGameLevel.values.length,
                  }),
                  style: const TextStyle(color: starGameMuted, fontSize: 13),
                ),
                if (_progress.saveFailed)
                  StarGameSaveNotice(onRetry: _progress.retrySave),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 10.0;
                    final columns = constraints.maxWidth >= 620
                        ? 3
                        : constraints.maxWidth >= 290 &&
                              MediaQuery.textScalerOf(context).scale(1) < 1.6
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final level in StarGameLevel.values)
                          SizedBox(
                            width: width,
                            child: _LevelCard(
                              level: level,
                              record: _progress.best(level),
                              locked: !_progress.isUnlocked(level),
                              onTap: _progress.loading
                                  ? null
                                  : () => _play(level),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _GameHero extends StatelessWidget {
  const _GameHero({
    required this.next,
    required this.loading,
    required this.onPlay,
  });

  final StarGameLevel next;
  final bool loading;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF233368), Color(0xFF32285C)],
      ),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: const Color(0xFF53629D)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showArt =
              constraints.maxWidth >= 305 &&
              MediaQuery.textScalerOf(context).scale(1) < 1.45;
          return Stack(
            children: [
              if (showArt)
                Positioned.fill(
                  left: constraints.maxWidth * .56,
                  child: ColoredBox(
                    color: const Color(0x204E4594),
                    child: StarGameConstellation(
                      level: next,
                      lit: starGameQuestionCount,
                      preview: true,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  18,
                  showArt ? constraints.maxWidth * .38 : 18,
                  18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 23,
                      color: starGameGold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.getText(AppKeys.gamesTitle),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.getText(AppKeys.gamesPitch),
                      style: const TextStyle(
                        color: starGameMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 14),
                    StarGameButton(
                      label: context.formatText(AppKeys.gamesStart, {
                        'level': next.number,
                      }),
                      icon: Icons.play_arrow_rounded,
                      onPressed: loading ? null : onPlay,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.record,
    required this.locked,
    required this.onTap,
  });

  final StarGameLevel level;
  final StarGameRecord? record;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = locked ? starGameMuted : starGameAccent(level);
    final lockHint = context.formatText(AppKeys.gamesLocked, {
      'level': level.number - 1,
    });
    return Material(
      color: locked ? const Color(0xFF1B254B) : starGamePanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: BorderSide(
          color: locked ? starGameLine : accent.withValues(alpha: .50),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('star-game-level-${level.number}'),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.formatText(AppKeys.gamesLevel, {
                        'level': level.number,
                      }),
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (locked)
                    Tooltip(
                      message: lockHint,
                      child: Icon(Icons.lock_rounded, color: accent, size: 16),
                    )
                  else
                    StarGameRating(stars: record?.stars ?? 0, size: 15),
                ],
              ),
              SizedBox(
                height: 50,
                child: Opacity(
                  opacity: locked ? .65 : 1,
                  child: StarGameConstellation(
                    level: level,
                    lit: record?.correct ?? 0,
                    preview: true,
                  ),
                ),
              ),
              Text(
                context.getText(level.nameKey),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.getText(level.skillKey),
                style: const TextStyle(color: starGameMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
