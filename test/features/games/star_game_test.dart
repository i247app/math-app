import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/games/controllers/star_game_progress.dart';
import 'package:numi/features/games/controllers/star_game_round.dart';
import 'package:numi/features/games/models/star_game.dart';
import 'package:numi/features/games/screens/star_game_tab.dart';
import 'package:numi/features/games/widgets/star_game_answer_gem.dart';
import 'package:numi/features/games/widgets/star_game_art.dart';
import 'package:numi/features/games/widgets/star_game_comet_effects.dart';
import 'package:numi/features/games/widgets/star_game_result_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('all levels generate ten distinct questions with one valid choice', () {
    final random = Random(41);
    for (final level in StarGameLevel.values) {
      for (var run = 0; run < 12; run++) {
        final questions = buildStarGameQuestions(level, random: random);
        expect(
          questions.map((question) => question.expression).toSet(),
          hasLength(10),
        );
        for (final question in questions) {
          expect(question.answer, _evaluate(question.expression));
          expect(question.choices.toSet(), hasLength(4));
          expect(question.choices, contains(question.answer));
          expect(
            question.choices,
            everyElement(inInclusiveRange(0, level.maxAnswer)),
          );
        }
      }
    }
    expect([4, 5, 6, 7, 8, 9, 10].map(starGameStars), [0, 1, 1, 2, 2, 3, 3]);
  });

  test(
    'records favor accuracy, unlock the next level and stay profile scoped',
    () async {
      SharedPreferences.setMockInitialValues({});
      final child = StarGameProgress('child-1');
      const level = StarGameLevel.kite;
      await _waitForProgress(child);
      expect(child.isUnlocked(level.next!), isFalse);
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 4, elapsed: Duration(seconds: 20)),
        ),
        isTrue,
      );
      expect(child.isUnlocked(level.next!), isFalse);
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 9, elapsed: Duration(seconds: 35)),
        ),
        isTrue,
      );
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 10, elapsed: Duration(seconds: 42)),
        ),
        isTrue,
      );
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 9, elapsed: Duration(seconds: 30)),
        ),
        isFalse,
      );
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 10, elapsed: Duration(seconds: 40)),
        ),
        isTrue,
      );
      expect(
        child.record(
          level,
          const StarGameRecord(correct: 10, elapsed: Duration(seconds: 41)),
        ),
        isFalse,
      );
      expect(child.isUnlocked(level.next!), isTrue);
      await Future<void>.delayed(Duration.zero);
      child.dispose();

      final reopened = StarGameProgress('child-1');
      final sibling = StarGameProgress('child-2');
      await _waitForProgress(reopened);
      await _waitForProgress(sibling);
      expect(reopened.best(level)?.correct, 10);
      expect(reopened.best(level)?.elapsed, const Duration(seconds: 40));
      expect(reopened.isUnlocked(level.next!), isTrue);
      expect(sibling.isUnlocked(level.next!), isFalse);
      reopened.dispose();
      sibling.dispose();
    },
  );

  testWidgets(
    'result rewards enter from the foreground in left, right, center order',
    (tester) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await tester.pumpWidget(_ratingApp(lingo, 3));

      Finder slot(int index) =>
          find.byKey(ValueKey('star-game-result-slot-$index'));
      Finder reward(int index) =>
          find.byKey(ValueKey('star-game-result-reward-$index'));
      expect(
        tester.getCenter(slot(0)).dx,
        lessThan(tester.getCenter(slot(2)).dx),
      );
      expect(
        tester.getCenter(slot(2)).dx,
        lessThan(tester.getCenter(slot(1)).dx),
      );
      expect(
        tester.getSize(slot(2)).width,
        greaterThan(tester.getSize(slot(0)).width),
      );
      expect(
        tester.getSize(slot(0)).width,
        closeTo(tester.getSize(slot(1)).width, .01),
      );
      expect(reward(0), findsNothing);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      expect(reward(0), findsOneWidget);
      expect(reward(1), findsNothing);
      expect(reward(2), findsNothing);
      expect(
        tester.getCenter(reward(0)).dy,
        lessThan(tester.getCenter(slot(0)).dy),
      );

      await tester.pump(const Duration(milliseconds: 350));
      expect(reward(1), findsOneWidget);
      expect(reward(2), findsNothing);

      await tester.pump(const Duration(milliseconds: 350));
      expect(reward(2), findsOneWidget);
      expect(
        tester.getCenter(reward(2)).dy,
        lessThan(tester.getCenter(slot(2)).dy),
      );
      await tester.pumpAndSettle();
      for (var index = 0; index < 3; index++) {
        expect(
          (tester.getCenter(reward(index)) - tester.getCenter(slot(index)))
              .distance,
          lessThan(.01),
        );
      }
    },
  );

  testWidgets('reduced motion shows exactly the earned rewards immediately', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    for (var stars = 0; stars <= 3; stars++) {
      await tester.pumpWidget(_ratingApp(lingo, stars, reduceMotion: true));
      for (var index = 0; index < 3; index++) {
        final slot = find.byKey(ValueKey('star-game-result-slot-$index'));
        final reward = find.byKey(ValueKey('star-game-result-reward-$index'));
        expect(slot, findsOneWidget);
        expect(reward, index < stars ? findsOneWidget : findsNothing);
        if (index < stars) {
          expect(
            (tester.getCenter(reward) - tester.getCenter(slot)).distance,
            lessThan(.01),
          );
        }
      }
    }
  });

  testWidgets(
    'streak feedback resets on a mistake and a perfect round finishes its celebration',
    (tester) async {
      final questions = buildStarGameQuestions(
        StarGameLevel.kite,
        random: Random(19),
      );
      final practice = StarGameRound(questions: questions, onFinish: (_) {});
      addTearDown(practice.dispose);
      await tester.pump(const Duration(seconds: 3));
      for (final (right, streak) in [
        (true, false),
        (true, false),
        (false, false),
        (true, false),
        (true, false),
        (true, true),
      ]) {
        final question = practice.question;
        final choice = right
            ? question.answer
            : question.choices.firstWhere((value) => value != question.answer);
        expect(practice.answer(choice, reduceMotion: true), isTrue);
        expect(practice.streakCelebration, streak);
        if (right) {
          expect(practice.feedbackDuration, const Duration(milliseconds: 550));
        }
        await tester.pump(practice.feedbackDuration);
      }
      practice.pause();

      StarGameRecord? record;
      final perfect = StarGameRound(
        questions: questions,
        onFinish: (result) => record = result,
      );
      addTearDown(perfect.dispose);
      await tester.pump(const Duration(seconds: 3));
      for (var i = 0; i < questions.length - 1; i++) {
        expect(perfect.answer(perfect.question.answer), isTrue);
        expect(perfect.streakCelebration, (i + 1) % 3 == 0);
        await tester.pump(perfect.feedbackDuration);
      }
      expect(perfect.answer(perfect.question.answer), isTrue);
      expect(perfect.perfectRound, isTrue);
      await tester.pump(const Duration(milliseconds: 950));
      expect(perfect.phase, StarGamePhase.feedback);
      expect(record, isNull);
      await tester.pump(const Duration(milliseconds: 100));
      expect(record?.correct, starGameQuestionCount);
      expect(perfect.phase, StarGamePhase.result);
    },
  );

  testWidgets(
    'play on a small phone, pause, earn two stars and open level two',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: StarGameTab(bottomPadding: 88)),
          ),
        ),
      );

      final secondCard = find.byKey(const ValueKey('star-game-level-2'));
      expect(secondCard, findsNothing);
      expect(
        tester.widget<StarGameBackdrop>(find.byType(StarGameBackdrop)).banner,
        isTrue,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vua tính nhẩm'));
      await tester.pumpAndSettle();
      expect(find.byType(StarGamePlayBackdrop), findsNothing);
      expect(tester.widget<InkWell>(secondCard).onTap, isNull);
      await tester.tap(find.text('Chơi màn 1'));
      await tester.pumpAndSettle();
      final gameplayBackdrop = find.byType(StarGamePlayBackdrop);
      expect(gameplayBackdrop, findsOneWidget);
      final picture = tester.widget<Image>(
        find.descendant(of: gameplayBackdrop, matching: find.byType(Image)),
      );
      expect(
        (picture.image as AssetImage).assetName,
        StarGamePlayBackdrop.assetPath,
      );
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      expect(find.byIcon(Icons.volume_off_rounded), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      final equation = find.byKey(const ValueKey('star-game-equation'));
      final firstQuestion = tester.widget<Text>(equation).data;
      final clock = find.byKey(const ValueKey('star-game-clock'));
      expect(clock, findsOneWidget);
      expect(tester.getRect(clock).left, lessThan(64));
      expect(tester.getCenter(find.byTooltip('Tạm dừng')).dx, greaterThan(240));
      expect(find.byType(LinearProgressIndicator), findsNothing);

      final stars = find.byWidgetPredicate((widget) {
        final key = widget.key;
        return widget is InkWell &&
            key is ValueKey<String> &&
            key.value.startsWith('star-game-answer-');
      });
      expect(stars, findsNWidgets(4));
      StarGameAnswerGem gem(Finder star) =>
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: star,
                      matching: find.byWidgetPredicate(
                        (widget) =>
                            widget is CustomPaint &&
                            widget.painter is StarGameAnswerGem,
                      ),
                    ),
                  )
                  .painter!
              as StarGameAnswerGem;
      for (var index = 0; index < 4; index++) {
        expect(gem(stars.at(index)).tone, StarGameAnswerTone.sapphire);
      }
      List<Rect> starBounds() => [
        for (var i = 0; i < 4; i++) tester.getRect(stars.at(i)),
      ];
      final firstLayout = starBounds();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump(const Duration(seconds: 8));
      expect(find.text('Đang tạm dừng'), findsOneWidget);
      expect(equation, findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Đang tạm dừng'), findsOneWidget);
      await tester.tap(find.text('Tiếp tục'));
      await tester.pump();
      expect(tester.widget<Text>(equation).data, firstQuestion);
      expect(starBounds(), firstLayout);

      var previousLayout = firstLayout;
      for (var index = 0; index < starGameQuestionCount; index++) {
        final hitTargets = starBounds();
        if (index > 0) expect(hitTargets, isNot(equals(previousLayout)));
        previousLayout = hitTargets;
        for (var i = 0; i < hitTargets.length; i++) {
          final target = hitTargets[i];
          expect(target.width, greaterThanOrEqualTo(48));
          expect(target.height, greaterThanOrEqualTo(48));
          expect(target.left, greaterThanOrEqualTo(0));
          expect(target.right, lessThanOrEqualTo(320));
          expect(target.bottom, lessThanOrEqualTo(548));
          for (final other in hitTargets.skip(i + 1)) {
            expect(target.inflate(3).overlaps(other), isFalse);
            expect((target.center.dy - other.center.dy).abs(), greaterThan(8));
          }
        }
        final question = tester.widget<Text>(equation).data!.split(' =').first;
        final answer = _evaluate(question);
        final correctChoice = find.byKey(ValueKey('star-game-answer-$answer'));
        final isCorrect = index < 7;
        final chosen = isCorrect
            ? correctChoice
            : find.byWidgetPredicate((widget) {
                final key = widget.key;
                return widget is InkWell &&
                    key is ValueKey<String> &&
                    key.value.startsWith('star-game-answer-') &&
                    key.value != 'star-game-answer-$answer';
              }).first;
        await tester.ensureVisible(chosen);
        await tester.tap(chosen);
        await tester.tap(correctChoice);
        await tester.pump();
        final flight = find.byKey(const ValueKey('star-game-flying-number'));
        final constellation = find.byType(StarGameConstellation);
        final effects = find.byType(StarGameCometEffects);
        final displayedAnswer = find.descendant(
          of: find.byKey(const ValueKey('star-game-answer-slot')),
          matching: find.text('$answer'),
        );
        if (isCorrect) {
          expect(effects, findsOneWidget);
          expect(flight, findsNothing);
          await tester.pump(const Duration(milliseconds: 120));
          expect(flight, findsOneWidget);
          expect(displayedAnswer, findsNothing);
          expect(gem(correctChoice).charge, greaterThan(0));
          expect(
            tester.widget<StarGameConstellation>(constellation).lit,
            index,
          );
          await tester.pump(const Duration(milliseconds: 185));
          expect(flight, findsNothing);
          expect(displayedAnswer, findsOneWidget);
          expect(gem(correctChoice).tone, StarGameAnswerTone.correct);
          expect(
            tester.widget<StarGameConstellation>(constellation).lit,
            index,
          );
          await tester.pump(const Duration(milliseconds: 205));
          final drawing = tester.widget<StarGameConstellation>(constellation);
          expect(drawing.lit, index + 1);
          expect(drawing.newestLinkProgress, lessThan(1));
          expect(drawing.sweepProgress != null, (index + 1) % 3 == 0);
          await tester.pump(const Duration(milliseconds: 640));
        } else {
          expect(effects, findsNothing);
          expect(flight, findsNothing);
          expect(displayedAnswer, findsOneWidget);
          expect(find.text('Đáp án đúng là $answer'), findsOneWidget);
          expect(gem(chosen).tone, StarGameAnswerTone.wrong);
          expect(gem(correctChoice).tone, StarGameAnswerTone.correct);
          await tester.pump(const Duration(milliseconds: 1150));
        }
      }

      expect(find.text('Hoàn thành màn chơi!'), findsOneWidget);
      expect(gameplayBackdrop, findsNothing);
      expect(find.text('7/10'), findsOneWidget);
      expect(
        tester
            .widget<StarGameResultRating>(find.byType(StarGameResultRating))
            .stars,
        2,
      );
      expect(find.text('Kỷ lục mới'), findsOneWidget);
      expect(find.text('Đã mở khóa Cá Voi!'), findsOneWidget);
      final next = find.text('Màn tiếp theo');
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pump();
      expect(find.bySemanticsLabel('Cá Voi'), findsOneWidget);
      expect(find.text('Sẵn sàng thắp sao?'), findsOneWidget);

      await tester.tap(find.byTooltip('Tạm dừng'));
      await tester.pump();
      await tester.tap(find.text('Về bản đồ'));
      await tester.pumpAndSettle();
      expect(tester.widget<InkWell>(secondCard).onTap, isNotNull);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Games'), findsOneWidget);
      await tester.tap(find.text('Vua tính nhẩm'));
      await tester.pumpAndSettle();
      expect(find.text('Chơi màn 2'), findsOneWidget);
      expect(tester.widget<InkWell>(secondCard).onTap, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _ratingApp(
  LingoProvider lingo,
  int stars, {
  bool reduceMotion = false,
}) => LingoScope(
  lingo: lingo,
  child: MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: reduceMotion),
          child: Center(child: StarGameResultRating(stars: stars)),
        ),
      ),
    ),
  ),
);

Future<void> _waitForProgress(StarGameProgress progress) async {
  while (progress.loading) {
    await Future<void>.delayed(Duration.zero);
  }
}

int _evaluate(String expression) {
  final parts = expression.replaceAll(RegExp(r'[()]'), '').split(' ');
  final left = int.parse(parts[0]);
  final right = int.parse(parts[2]);
  final first = switch (parts[1]) {
    '+' => left + right,
    '−' => left - right,
    '×' => left * right,
    '÷' => left ~/ right,
    _ => throw FormatException(expression),
  };
  if (parts.length == 3) return first;
  final last = int.parse(parts[4]);
  return parts[3] == '+' ? first + last : first - last;
}
