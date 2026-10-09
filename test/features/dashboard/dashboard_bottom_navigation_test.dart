import 'package:flutter/material.dart';
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
