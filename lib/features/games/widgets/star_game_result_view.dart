import 'package:material_ui/material_ui.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';
import 'package:numi/features/games/widgets/star_game_controls.dart';
import 'package:numi/features/games/widgets/star_game_result_rating.dart';

class StarGameResultView extends StatelessWidget {
  const StarGameResultView({
    super.key,
    required this.level,
    required this.result,
    required this.best,
    required this.newRecord,
    required this.unlockedNext,
    required this.onNext,
    required this.onReplay,
    required this.onExit,
    this.onRetrySave,
  });

  final StarGameLevel level;
  final StarGameRecord result;
  final StarGameRecord best;
  final bool newRecord;
  final bool unlockedNext;
  final VoidCallback? onNext;
  final VoidCallback onReplay;
  final VoidCallback onExit;
  final VoidCallback? onRetrySave;

  @override
  Widget build(BuildContext context) {
    final accent = starGameAccent(level);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          '${context.formatText(AppKeys.gamesLevel, {'level': level.number})} · ${context.getText(level.nameKey)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.getText(AppKeys.gamesDone),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 108,
          child: StarGameConstellation(level: level, lit: result.correct),
        ),
        Center(child: StarGameResultRating(stars: result.stars)),
        const SizedBox(height: 8),
        _ResultStats(result: result, best: best, newRecord: newRecord),
        if (onRetrySave case final retry?) StarGameSaveNotice(onRetry: retry),
        if (unlockedNext || result.stars == 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              unlockedNext
                  ? context.formatText(AppKeys.gamesNextUnlocked, {
                      'name': context.getText(level.next!.nameKey),
                    })
                  : context.formatText(AppKeys.gamesRetryGoal, {
                      'count': starGameMilestones.first - result.correct,
                    }),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        const SizedBox(height: 16),
        StarGameButton(
          label: context.getText(
            onNext == null ? AppKeys.gamesReplay : AppKeys.gamesNext,
          ),
          icon: onNext == null
              ? Icons.replay_rounded
              : Icons.arrow_forward_rounded,
          onPressed: onNext ?? onReplay,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            if (onNext != null)
              TextButton.icon(
                onPressed: onReplay,
                style: TextButton.styleFrom(foregroundColor: starGameMuted),
                icon: const Icon(Icons.replay_rounded, size: 19),
                label: Text(context.getText(AppKeys.gamesReplay)),
              ),
            TextButton.icon(
              onPressed: onExit,
              style: TextButton.styleFrom(foregroundColor: starGameMuted),
              icon: const Icon(Icons.map_outlined, size: 19),
              label: Text(context.getText(AppKeys.gamesBackToMap)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultStats extends StatelessWidget {
  const _ResultStats({
    required this.result,
    required this.best,
    required this.newRecord,
  });

  final StarGameRecord result;
  final StarGameRecord best;
  final bool newRecord;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: starGamePanel,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: starGameLine),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: context.getText(AppKeys.gamesAnswers),
                value: '${result.correct}/$starGameQuestionCount',
              ),
            ),
            Expanded(
              child: _Stat(
                label: context.getText(AppKeys.gamesThisTime),
                value: starGameTime(result.elapsed),
              ),
            ),
          ],
        ),
        const Divider(height: 20, color: starGameLine),
        Row(
          children: [
            Icon(
              newRecord
                  ? Icons.emoji_events_rounded
                  : Icons.emoji_events_outlined,
              color: starGameGold,
              size: 25,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.getText(
                      newRecord
                          ? AppKeys.gamesNewRecord
                          : AppKeys.gamesBestTime,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    context.formatText(AppKeys.gamesBestDetails, {
                      'score': best.correct,
                    }),
                    style: const TextStyle(color: starGameMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                starGameTime(best.elapsed),
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: starGameGold,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: starGameMuted, fontSize: 13),
      ),
    ],
  );
}
