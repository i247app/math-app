import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_order.dart';
import 'package:numi/features/dashboard/widgets/dashboard_bottom_navigation.dart';
import 'package:numi/features/profile/models/profile_role.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('nav labels stay level when a long label scales down', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const labels = ['HOME', 'ASSESSMENT', 'LEARNING', 'SETTINGS'];

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
                          active: index == 3,
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
  });

  test('parent and student swipes skip hidden Room and Games tabs', () {
    for (final role in [ProfileRole.parent, ProfileRole.student]) {
      expect(adjacentVisibleTab(role, 1, forward: true), learningTabIndex);
      expect(adjacentVisibleTab(role, learningTabIndex, forward: false), 1);
      expect(adjacentVisibleTab(role, learningTabIndex, forward: true), 4);
      expect(adjacentVisibleTab(role, 2, forward: true), isNull);
      expect(adjacentVisibleTab(role, 3, forward: false), isNull);
    }
    expect(visibleDashboardTabs(ProfileRole.teacher), [0, 1, 2, 3, 4]);
  });

  for (final role in [ProfileRole.parent, ProfileRole.student]) {
    testWidgets('$role shows Home, Thi, Learning, Settings only', (
      tester,
    ) async {
      final originalLanguage = AppLanguageState.current;
      final lingo = LingoProvider();
      final swipePosition = ValueNotifier<double?>(null);
      addTearDown(() {
        AppLanguageState.current = originalLanguage;
        lingo.dispose();
        swipePosition.dispose();
      });
      int? selectedTab;

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              bottomNavigationBar: DashboardBottomNavigation(
                bottomInset: 0,
                activeIndex: 0,
                activeRole: role,
                user: null,
                swipePosition: swipePosition,
                onTabSelected: (index) => selectedTab = index,
              ),
            ),
          ),
        ),
      );

      expect(visibleDashboardTabs(role), [0, 1, learningTabIndex, 4]);
      expect(find.text('THI'), findsOneWidget);
      expect(find.text('HỌC'), findsOneWidget);
      expect(find.text('PHÒNG'), findsNothing);
      expect(find.text('GAMES'), findsNothing);
      expect(find.byType(DashboardAnimatedNavItem), findsNWidgets(4));

      await tester.tap(find.text('HỌC'));
      await tester.pump();
      expect(selectedTab, learningTabIndex);

      await lingo.setLanguage(AppLanguage.en);
      await tester.pump();
      expect(find.text('ASSESSMENT'), findsOneWidget);
      expect(find.text('LEARNING'), findsOneWidget);
      expect(find.text('ROOM'), findsNothing);
      expect(find.text('GAMES'), findsNothing);
    });
  }
}
