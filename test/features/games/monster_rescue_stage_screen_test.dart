import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/games/presentation/monster_rescue_stage_screen.dart';

void main() {
  testWidgets(
    'plays the rescue mission from intro through collectible reward',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: LingoScope(
            lingo: lingo,
            child: const MonsterRescueStageScreen(level: 1),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('rescue-intro-title')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rescue-start')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('rescue-right-gate-0')));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const ValueKey('rescue-right-gate-1')));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byKey(const ValueKey('rescue-bridge')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rescue-bridge-plus')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('rescue-bridge-plus')));
      await tester.pump();
      expect(find.text('3'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('rescue-open-bridge')));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byKey(const ValueKey('rescue-boss')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rescue-boss-core-0')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const ValueKey('rescue-boss-core-1')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byKey(const ValueKey('rescue-boss-core-2')));
      await tester.pump(const Duration(seconds: 2));

      expect(
        find.byKey(const ValueKey('rescue-complete-title')),
        findsOneWidget,
      );
      expect(find.textContaining('Numi Điện'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
