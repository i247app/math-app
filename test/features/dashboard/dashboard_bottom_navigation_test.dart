import 'package:material_ui/material_ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/dashboard/widgets/dashboard_bottom_navigation.dart';
import 'package:numi/features/games/screens/games_coming_soon_tab.dart';
import 'package:numi/features/profile/models/profile_role.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('nav labels stay level when a long label scales down', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final labels in const [
      ['HOME', 'LEARNING', 'GAMES', 'SETTINGS'],
      ['HOME', 'CLASSROOM', 'STUDY', 'MEMBERS', 'SETTINGS'],
    ]) {
      for (final width in [320.0, 390.0]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width - 40,
                  height: 60,
                  child: Row(
                    children: [
                      for (var index = 0; index < labels.length; index++)
                        Expanded(
                          child: DashboardAnimatedNavItem(
                            data: DashboardNavItemData(
                              Icons.home_rounded,
                              labels[index],
                              null,
                            ),
                            active: index == labels.length - 1,
                            onTap: () {},
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final bottoms = [
          for (final label in labels) tester.getBottomLeft(find.text(label)).dy,
        ];
        expect(
          bottoms.reduce((a, b) => a > b ? a : b) -
              bottoms.reduce((a, b) => a < b ? a : b),
          lessThan(0.5),
        );
      }
    }
  });

  test('parent and student swipes skip hidden Assessment and Room tabs', () {
    for (final role in [ProfileRole.parent, ProfileRole.student]) {
      expect(
        adjacentVisibleTab(role, DashboardTabId.home, forward: true),
        DashboardTabId.learning,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.learning, forward: false),
        DashboardTabId.home,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.learning, forward: true),
        DashboardTabId.games,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.games, forward: false),
        DashboardTabId.learning,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.games, forward: true),
        DashboardTabId.settings,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.assessment, forward: true),
        isNull,
      );
      expect(
        adjacentVisibleTab(role, DashboardTabId.room, forward: true),
        isNull,
      );
    }
    expect(visibleDashboardTabs(ProfileRole.teacher), [
      DashboardTabId.home,
      DashboardTabId.classroom,
      DashboardTabId.study,
      DashboardTabId.members,
      DashboardTabId.settings,
    ]);
  });

  test('slide direction follows visible tab order', () {
    for (final role in [ProfileRole.parent, ProfileRole.student]) {
      expect(
        isForwardVisibleTabTransition(
          role,
          DashboardTabId.learning,
          DashboardTabId.games,
        ),
        isTrue,
      );
      expect(
        isForwardVisibleTabTransition(
          role,
          DashboardTabId.games,
          DashboardTabId.learning,
        ),
        isFalse,
      );
      expect(
        isForwardVisibleTabTransition(
          role,
          DashboardTabId.games,
          DashboardTabId.settings,
        ),
        isTrue,
      );
      expect(
        isForwardVisibleTabTransition(
          role,
          DashboardTabId.settings,
          DashboardTabId.games,
        ),
        isFalse,
      );
      expect(
        isForwardVisibleTabTransition(
          role,
          DashboardTabId.home,
          DashboardTabId.learning,
        ),
        isTrue,
      );
    }
    expect(
      isForwardVisibleTabTransition(
        ProfileRole.teacher,
        DashboardTabId.members,
        DashboardTabId.settings,
      ),
      isTrue,
    );
  });

  for (final role in [ProfileRole.parent, ProfileRole.student]) {
    testWidgets('$role shows Home, Learning, Games, Settings', (tester) async {
      final originalLanguage = AppLanguageState.current;
      final lingo = LingoProvider();
      final swipePosition = ValueNotifier<double?>(null);
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
        swipePosition.dispose();
      });
      DashboardTabId? selectedTab;

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              bottomNavigationBar: DashboardBottomNavigation(
                bottomInset: 0,
                activeTab: DashboardTabId.home,
                activeRole: role,
                user: null,
                swipePosition: swipePosition,
                onTabSelected: (index) => selectedTab = index,
              ),
            ),
          ),
        ),
      );

      expect(visibleDashboardTabs(role), [
        DashboardTabId.home,
        DashboardTabId.learning,
        DashboardTabId.games,
        DashboardTabId.settings,
      ]);
      expect(find.text('THI'), findsNothing);
      expect(find.text('HỌC'), findsOneWidget);
      expect(find.text('PHÒNG'), findsNothing);
      expect(find.text('GAMES'), findsOneWidget);
      expect(find.byType(DashboardAnimatedNavItem), findsNWidgets(4));

      await tester.tap(find.text('HỌC'));
      await tester.pump();
      expect(selectedTab, DashboardTabId.learning);

      await tester.tap(find.text('GAMES'));
      await tester.pump();
      expect(selectedTab, DashboardTabId.games);

      await lingo.setLanguage(AppLanguage.en);
      await tester.pump();
      expect(find.text('ASSESSMENT'), findsNothing);
      expect(find.text('LEARNING'), findsOneWidget);
      expect(find.text('ROOM'), findsNothing);
      expect(find.text('GAMES'), findsOneWidget);
    });
  }

  for (final role in [ProfileRole.parent, ProfileRole.teacher]) {
    testWidgets('$role indicator stretches and contracts in both directions', (
      tester,
    ) async {
      await _pumpAnimatedNavigation(tester, role: role);
      final indicator = find.byKey(
        const ValueKey('dashboard-active-indicator'),
      );
      final items = find.byType(DashboardAnimatedNavItem);
      final start = tester.getRect(indicator);

      await tester.tap(items.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 111));
      final stretchedRight = tester.getRect(indicator);
      expect(stretchedRight.width, greaterThan(start.width * 1.45));
      expect(stretchedRight.left, greaterThan(start.left));
      expect(stretchedRight.left, lessThan(start.left + start.width * 0.5));
      await tester.pump(const Duration(milliseconds: 689));
      final next = tester.getRect(indicator);
      expect(next.width, closeTo(start.width, 0.01));
      expect(next.left, closeTo(start.right, 0.01));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getRect(indicator), next);

      await tester.tap(items.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 111));
      final stretchedLeft = tester.getRect(indicator);
      expect(stretchedLeft.width, greaterThan(start.width * 1.45));
      expect(stretchedLeft.right, lessThan(next.right));
      expect(stretchedLeft.right, greaterThan(next.right - start.width * 0.5));
      await tester.pump(const Duration(milliseconds: 689));
      expect(tester.getRect(indicator), start);
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getRect(indicator), start);
    });
  }

  testWidgets('indicator holds its tail, overshoots and springs back like A', (
    tester,
  ) async {
    await _pumpAnimatedNavigation(tester);
    final indicator = find.byKey(const ValueKey('dashboard-active-indicator'));
    final items = find.byType(DashboardAnimatedNavItem);
    final start = tester.getRect(indicator);

    await tester.tap(items.at(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 55));
    final pulling = tester.getRect(indicator);
    expect(pulling.left, closeTo(start.left, 0.01));
    expect(pulling.right, greaterThan(start.right));
    expect(pulling.height, start.height);

    await tester.pump(const Duration(milliseconds: 198));
    final overshoot = tester.getRect(indicator);
    final targetLeft = start.left + 2 * start.width;
    expect(overshoot.left, greaterThan(targetLeft));
    expect(overshoot.right, greaterThan(targetLeft + start.width));
    expect(overshoot.width, lessThan(start.width * 1.3));
    expect(overshoot.height, start.height);

    await tester.pump(const Duration(milliseconds: 253));
    expect(tester.getRect(indicator).left, lessThan(targetLeft));
    await tester.pumpAndSettle();
    final target = tester.getRect(indicator);
    expect(target.left, closeTo(targetLeft, 0.01));
    expect(target.width, closeTo(start.width, 0.01));

    await tester.tap(items.at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 253));
    expect(tester.getRect(indicator).left, lessThan(start.right));
    await tester.pumpAndSettle();
    expect(tester.getRect(indicator).left, closeTo(start.right, 0.01));
  });

  testWidgets('spring stays inside navbar when travelling to either end', (
    tester,
  ) async {
    await _pumpAnimatedNavigation(tester);
    final indicator = find.byKey(const ValueKey('dashboard-active-indicator'));
    final items = find.byType(DashboardAnimatedNavItem);
    final start = tester.getRect(indicator);
    final maxRight = start.left + start.width * 4;
    for (final target in [items.last, items.first]) {
      await tester.tap(target);
      await tester.pump();
      for (var frame = 0; frame < 80; frame++) {
        await tester.pump(const Duration(milliseconds: 10));
        final bounds = tester.getRect(indicator);
        expect(bounds.left, greaterThanOrEqualTo(start.left));
        expect(bounds.right, lessThanOrEqualTo(maxRight + 0.01));
        expect(bounds.width, greaterThan(0));
      }
    }
  });

  testWidgets('rapid tab changes continue from the visible stretched bounds', (
    tester,
  ) async {
    await _pumpAnimatedNavigation(tester);
    final indicator = find.byKey(const ValueKey('dashboard-active-indicator'));
    final items = find.byType(DashboardAnimatedNavItem);
    final start = tester.getRect(indicator);

    await tester.tap(items.last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 49));
    final beforeRetarget = tester.getRect(indicator);
    expect(beforeRetarget.width, greaterThan(start.width));

    await tester.tap(items.first);
    await tester.pump();
    final afterRetarget = tester.getRect(indicator);
    expect(afterRetarget.left, closeTo(beforeRetarget.left, 0.01));
    expect(afterRetarget.right, closeTo(beforeRetarget.right, 0.01));
    await tester.pumpAndSettle();
    expect(tester.getRect(indicator), start);
  });

  testWidgets('swipe stretches the indicator and cancellation restores it', (
    tester,
  ) async {
    final swipe = await _pumpAnimatedNavigation(tester);
    final indicator = find.byKey(const ValueKey('dashboard-active-indicator'));
    final start = tester.getRect(indicator);

    swipe.value = 0.5;
    await tester.pump();
    final stretched = tester.getRect(indicator);
    expect(stretched.width, greaterThan(start.width * 1.5));
    expect(stretched.left, greaterThan(start.left));
    expect(stretched.right, lessThan(start.right + start.width));

    swipe.value = 1;
    await tester.pump();
    expect(tester.getRect(indicator).width, closeTo(start.width, 0.01));
    expect(tester.getRect(indicator).left, closeTo(start.right, 0.01));

    swipe.value = 0;
    await tester.pump();
    swipe.value = null;
    await tester.pumpAndSettle();
    expect(tester.getRect(indicator), start);
  });

  testWidgets(
    'teacher navigation emits classroom, study and members identities',
    (tester) async {
      final originalLanguage = AppLanguageState.current;
      final lingo = LingoProvider();
      final swipePosition = ValueNotifier<double?>(null);
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
        swipePosition.dispose();
      });
      await lingo.setLanguage(AppLanguage.en);
      DashboardTabId? selected;
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              bottomNavigationBar: DashboardBottomNavigation(
                bottomInset: 0,
                activeTab: DashboardTabId.home,
                activeRole: ProfileRole.teacher,
                user: null,
                swipePosition: swipePosition,
                onTabSelected: (tab) => selected = tab,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(DashboardAnimatedNavItem), findsNWidgets(5));
      for (final entry in const {
        'CLASS': DashboardTabId.classroom,
        'STUDY': DashboardTabId.study,
        'MEMBERS': DashboardTabId.members,
        'SETTINGS': DashboardTabId.settings,
      }.entries) {
        await tester.tap(find.text(entry.key));
        await tester.pump();
        expect(selected, entry.value);
      }
    },
  );

  testWidgets('Games placeholder shows only mascot and localized message', (
    tester,
  ) async {
    final originalLanguage = AppLanguageState.current;
    final lingo = LingoProvider();
    addTearDown(() {
      AppLanguageState.current = originalLanguage;
      lingo.dispose();
    });

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: GamesComingSoonTab(bottomPadding: 88)),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Sắp ra mắt'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);

    await lingo.setLanguage(AppLanguage.en);
    await tester.pump();
    expect(find.text('Coming soon'), findsOneWidget);
  });
}

Future<ValueNotifier<double?>> _pumpAnimatedNavigation(
  WidgetTester tester, {
  ProfileRole role = ProfileRole.parent,
}) async {
  final lingo = LingoProvider();
  final swipe = ValueNotifier<double?>(null);
  addTearDown(lingo.dispose);
  addTearDown(swipe.dispose);
  var activeTab = DashboardTabId.home;
  await tester.pumpWidget(
    LingoScope(
      lingo: lingo,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: DashboardBottomNavigation(
              bottomInset: 0,
              activeTab: activeTab,
              activeRole: role,
              user: null,
              swipePosition: swipe,
              onTabSelected: (tab) => setState(() => activeTab = tab),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return swipe;
}
