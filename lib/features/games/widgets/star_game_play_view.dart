import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/games/controllers/star_game_round.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:numi/features/games/widgets/star_game_answer_gem.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';
import 'package:numi/features/games/widgets/star_game_comet_effects.dart';

const _answerGap = 8.0;
const _answerStagger = 10.0;

class StarGamePlayView extends StatelessWidget {
  const StarGamePlayView({
    super.key,
    required this.level,
    required this.round,
    required this.height,
    required this.onPause,
    required this.onAnswer,
  });

  final StarGameLevel level;
  final StarGameRound round;
  final double height;
  final VoidCallback onPause;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: math.max(height, 406),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _Clock(clock: round.clock),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.pause_rounded),
              tooltip: context.getText(AppKeys.gamesPause),
              onPressed: onPause,
              style: IconButton.styleFrom(
                backgroundColor: starGameInk.withValues(alpha: .82),
                foregroundColor: Colors.white,
                minimumSize: const Size.square(48),
              ),
            ),
          ],
        ),
        Expanded(
          child: _PlayScene(level: level, round: round, onAnswer: onAnswer),
        ),
      ],
    ),
  );
}

class _Clock extends StatelessWidget {
  const _Clock({required this.clock});

  static const _foreground = Color(0xFFFFF7E7);
  final ValueNotifier<Duration> clock;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const ShapeDecoration(
      color: Color(0xFFE04540),
      shape: StadiumBorder(),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: _foreground, size: 19),
          const SizedBox(width: 7),
          Flexible(
            child: ValueListenableBuilder(
              valueListenable: clock,
              builder: (context, elapsed, _) => Text(
                starGameTime(elapsed),
                key: const ValueKey('star-game-clock'),
                semanticsLabel:
                    '${context.getText(AppKeys.gamesThisTime)} ${starGameTime(elapsed)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _foreground,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PlayScene extends StatelessWidget {
  const _PlayScene({
    required this.level,
    required this.round,
    required this.onAnswer,
  });

  final StarGameLevel level;
  final StarGameRound round;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    final countdown = round.phase == StarGamePhase.countdown;
    final feedback = round.phase == StarGamePhase.feedback;
    final question = round.question;
    final correct = feedback && round.selected == question.answer;
    final animated = correct && !MediaQuery.disableAnimationsOf(context);
    final duration = animated ? round.feedbackDuration : Duration.zero;
    final streak = animated && round.streakCelebration;
    final perfect = animated && round.perfectRound;
    final accent = starGameAccent(level);
    final expression = '${question.expression} =';
    final equationStyle = DefaultTextStyle.of(context).style.copyWith(
      color: Colors.white,
      fontFamily: starGameNumberFont,
      fontSize: 60,
      fontWeight: FontWeight.w900,
      height: 1,
      shadows: [
        const Shadow(
          color: Color(0xAA101839),
          offset: Offset(0, 2),
          blurRadius: 7,
        ),
        Shadow(color: accent.withValues(alpha: .40), blurRadius: 21),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final slotWidth = (width * .20).clamp(50.0, 72.0);
        final textPainter = TextPainter(
          text: TextSpan(text: expression, style: equationStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        const equationGap = 11.0;
        final textWidth = math.min(
          textPainter.width.ceilToDouble(),
          width - slotWidth - equationGap,
        );
        textPainter.dispose();

        final equationLeft = (width - textWidth - equationGap - slotWidth) / 2;
        final slot = Offset(width - equationLeft - slotWidth / 2, height * .45);
        final answerArea = Rect.fromLTRB(
          6,
          slot.dy + 70,
          width - 6,
          height - 14,
        );
        final columnLimit = (answerArea.width - 3 * _answerGap) / 4;
        final rowLimit =
            (answerArea.height - _answerGap - 2 * _answerStagger) / 2;
        final starSize = math
            .min(width * .24, math.max(columnLimit, rowLimit))
            .clamp(48.0, 94.0);
        // Keep a question's stars in place during feedback and after resuming.
        final starCenters = _scatterAnswers(
          answerArea.deflate(starSize / 2),
          starSize,
          Object.hash(round.index, question.expression),
        );
        final constellation = Rect.fromLTWH(
          0,
          height * .035,
          width,
          height * .347,
        );
        const launchAt = StarGameCometEffects.launchAt;
        const fillAt = StarGameCometEffects.fillAt;
        const lightAt = StarGameCometEffects.lightAt;
        final nextStar = animated
            ? constellation.topLeft +
                  starGameConstellationPoints(
                    level,
                    constellation.size,
                  )[round.correct - 1]
            : null;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: duration.inMilliseconds.toDouble()),
          duration: duration,
          builder: (context, elapsed, _) {
            final inFlight =
                animated && elapsed >= launchAt && elapsed < fillAt;
            final reveal = feedback && (!animated || elapsed >= fillAt);
            final lightsUp = animated && elapsed >= lightAt;
            final charge = math.sin(
              math.pi * StarGameCometEffects.progress(elapsed, 0, fillAt),
            );
            return Stack(
              children: [
                Positioned.fromRect(
                  rect: constellation,
                  child: Semantics(
                    label: context.getText(level.nameKey),
                    image: true,
                    child: StarGameConstellation(
                      level: level,
                      lit: round.correct - (animated && !lightsUp ? 1 : 0),
                      animateNewest: false,
                      newestLinkProgress: lightsUp
                          ? StarGameCometEffects.progress(
                              elapsed,
                              lightAt,
                              lightAt + 150,
                            )
                          : 1,
                      sweepProgress: streak && lightsUp
                          ? StarGameCometEffects.progress(elapsed, lightAt, 885)
                          : null,
                      celebrationGlow: perfect && lightsUp
                          ? math.sin(
                              math.pi *
                                  StarGameCometEffects.progress(
                                    elapsed,
                                    lightAt,
                                    1010,
                                  ),
                            )
                          : 0,
                    ),
                  ),
                ),
                if (countdown)
                  Positioned(
                    top: height * .44,
                    left: 0,
                    right: 0,
                    child: _Countdown(value: round.countdown, accent: accent),
                  )
                else ...[
                  Positioned(
                    left: equationLeft,
                    top: slot.dy - 34,
                    height: 68,
                    width: textWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          expression,
                          key: const ValueKey('star-game-equation'),
                          style: equationStyle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: slot.dx - slotWidth / 2,
                    top: slot.dy - 29,
                    width: slotWidth,
                    height: 58,
                    child: _AnswerSlot(
                      value: reveal ? question.answer : null,
                      accent: accent,
                    ),
                  ),
                  Positioned(
                    top: slot.dy + 35,
                    left: 0,
                    right: 0,
                    height: 31,
                    child: reveal
                        ? _Feedback(correct: correct, answer: question.answer)
                        : const SizedBox.shrink(),
                  ),
                  for (var i = 0; i < question.choices.length; i++)
                    Positioned(
                      left: starCenters[i].dx - starSize / 2,
                      top: starCenters[i].dy - starSize / 2,
                      width: starSize,
                      height: starSize,
                      child: Transform.scale(
                        scale: animated && question.choices[i] == round.selected
                            ? StarGameCometEffects.pressScale(elapsed)
                            : 1,
                        transformHitTests: false,
                        child: _AnswerStar(
                          value: question.choices[i],
                          charge:
                              animated && question.choices[i] == round.selected
                              ? charge
                              : 0,
                          correct:
                              reveal && question.choices[i] == question.answer,
                          wrong:
                              feedback &&
                              !correct &&
                              question.choices[i] == round.selected,
                          flying:
                              inFlight && question.choices[i] == round.selected,
                          onTap: feedback ? null : onAnswer,
                        ),
                      ),
                    ),
                  if (nextStar != null)
                    Positioned.fill(
                      child: StarGameCometEffects(
                        elapsed: elapsed,
                        number: question.answer,
                        answer:
                            starCenters[question.choices.indexOf(
                              question.answer,
                            )],
                        slot: slot,
                        star: nextStar,
                        streak: streak,
                        perfect: perfect,
                      ),
                    ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

List<Offset> _scatterAnswers(Rect bounds, double size, int seed) {
  const count = 4;
  final random = math.Random(seed);
  final centers = <Offset>[];
  final spacing = size + _answerGap;
  for (var attempt = 0; attempt < 96 && centers.length < count; attempt++) {
    final candidate = Offset(
      bounds.left + random.nextDouble() * bounds.width,
      bounds.top + random.nextDouble() * bounds.height,
    );
    if (centers.every((center) {
      final delta = candidate - center;
      return delta.dy.abs() >= _answerStagger &&
          (delta.dx.abs() >= spacing || delta.dy.abs() >= spacing);
    })) {
      centers.add(candidate);
    }
  }
  if (centers.length == count) {
    centers.sort((left, right) => left.dx.compareTo(right.dx));
    if (centers.last.dx - centers.first.dx >= bounds.width * .55) {
      return centers;
    }
  }

  if (bounds.width / (count - 1) < size + _answerGap / 2) {
    final upperLeft = random.nextBool() ? 0.0 : _answerStagger;
    final lowerLeft = random.nextBool() ? 0.0 : _answerStagger;
    return [
      Offset(
        bounds.left + bounds.width * .10 * random.nextDouble(),
        bounds.top + upperLeft,
      ),
      Offset(
        bounds.left + bounds.width * (.10 + .08 * random.nextDouble()),
        bounds.bottom - lowerLeft,
      ),
      Offset(
        bounds.right - bounds.width * (.10 + .08 * random.nextDouble()),
        bounds.top + _answerStagger - upperLeft,
      ),
      Offset(
        bounds.right - bounds.width * .10 * random.nextDouble(),
        bounds.bottom - _answerStagger + lowerLeft,
      ),
    ];
  }

  // Use independent columns when the answer area is shallow.
  final heights = [
    for (final base in [.65, .08, .88, .37]) base + random.nextDouble() * .02,
  ]..shuffle(random);
  return [
    for (var index = 0; index < count; index++)
      Offset(
        bounds.left + index * bounds.width / (count - 1),
        bounds.top + heights[index] * bounds.height,
      ),
  ];
}

class _AnswerSlot extends StatelessWidget {
  const _AnswerSlot({required this.value, required this.accent});

  final int? value;
  final Color accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const ValueKey('star-game-answer-slot'),
    decoration: BoxDecoration(
      color: starGameInk.withValues(alpha: value == null ? .30 : .46),
      border: Border.all(
        color: accent.withValues(alpha: value == null ? .78 : 1),
        width: 1.4,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: accent.withValues(alpha: .18), blurRadius: 12),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: value == null
          ? Semantics(
              label: context.getText(AppKeys.gamesAnswerBlank),
              child: Center(
                child: Container(
                  width: 24,
                  height: 2.5,
                  color: accent.withValues(alpha: .88),
                ),
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$value',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontFamily: starGameNumberFont,
                  fontSize: 44,
                ),
              ),
            ),
    ),
  );
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.correct, required this.answer});

  final bool correct;
  final int answer;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: starGameInk.withValues(alpha: .82),
            shape: const StadiumBorder(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Text(
              correct
                  ? context.getText(AppKeys.gamesCorrect)
                  : context.formatText(AppKeys.gamesCorrectAnswer, {
                      'answer': answer,
                    }),
              style: TextStyle(
                color: correct ? const Color(0xFFA4F3C6) : starGameMuted,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AnswerStar extends StatelessWidget {
  const _AnswerStar({
    required this.value,
    required this.charge,
    required this.correct,
    required this.wrong,
    required this.flying,
    required this.onTap,
  });

  final int value;
  final double charge;
  final bool correct;
  final bool wrong;
  final bool flying;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = correct
        ? StarGameAnswerTone.correct
        : wrong
        ? StarGameAnswerTone.wrong
        : StarGameAnswerTone.sapphire;
    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: ValueKey('star-game-answer-$value'),
        customBorder: const CircleBorder(),
        onTap: onTap == null ? null : () => onTap!(value),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: StarGameAnswerGem(tone: tone, charge: charge),
                    ),
                  ),
                ),
                SizedBox(
                  width: size * .64,
                  child: Opacity(
                    opacity: flying ? 0 : 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$value',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: starGameNumberFont,
                          fontSize: starGameAnswerFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Color(0xDD0A174C),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (correct || wrong)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: starGameInk,
                      ),
                      child: Icon(
                        correct ? Icons.check_rounded : Icons.close_rounded,
                        color: tone.rim,
                        size: 17,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
    if (!wrong || MediaQuery.disableAnimationsOf(context)) return button;
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 290),
      tween: Tween(begin: 0, end: 1),
      child: button,
      builder: (context, progress, child) => Transform.translate(
        offset: Offset(
          6 * math.sin(progress * math.pi * 5) * (1 - progress),
          0,
        ),
        child: child,
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.value, required this.accent});

  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Column(
      children: [
        Text(
          context.getText(AppKeys.gamesReady),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$value',
          style: TextStyle(
            color: accent,
            fontSize: 61,
            height: 1,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: accent.withValues(alpha: .63), blurRadius: 23),
            ],
          ),
        ),
      ],
    ),
  );
}
