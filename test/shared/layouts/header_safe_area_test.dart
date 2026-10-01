import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/home/widgets/teacher/teacher_top_bar.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/shared/widgets/profile_avatar_image.dart';

void main() {
  const size = Size(852, 393);
  const insets = [
    EdgeInsets.only(top: 24, bottom: 21),
    EdgeInsets.fromLTRB(59, 0, 0, 21),
    EdgeInsets.fromLTRB(0, 0, 59, 21),
    EdgeInsets.fromLTRB(59, 0, 59, 21),
  ];

  Future<void> pumpHeader(
    WidgetTester tester,
    Widget header,
    EdgeInsets padding, {
    bool parentSafeArea = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            platform: TargetPlatform.iOS,
            extensions: const [AppThemeColors.light],
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(padding: padding, viewPadding: padding),
            child: child!,
          ),
          home: Scaffold(
            body: parentSafeArea
                ? SafeArea(
                    top: false,
                    bottom: false,
                    child: Column(children: [header]),
                  )
                : Column(children: [header]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectInsideSafeWidth(
    WidgetTester tester,
    Finder finder,
    EdgeInsets padding,
  ) {
    final rect = tester.getRect(finder);
    expect(rect.left, greaterThanOrEqualTo(padding.left));
    expect(rect.right, lessThanOrEqualTo(size.width - padding.right));
  }

  for (final parentSafeArea in [false, true]) {
    testWidgets(
      'page header actions respect rotation and consumed insets ($parentSafeArea)',
      (tester) async {
        var backTaps = 0;
        var actionTaps = 0;
        for (final padding in insets) {
          await pumpHeader(
            tester,
            PageHeader(
              title: 'Thông báo',
              scale: 0.8,
              horizontalPadding: 12,
              actionWidth: 52,
              leading: IconButton(
                key: const ValueKey('back'),
                onPressed: () => backTaps++,
                icon: const Icon(Icons.arrow_back),
              ),
              trailing: IconButton(
                key: const ValueKey('action'),
                onPressed: () => actionTaps++,
                icon: const Icon(Icons.more_horiz),
              ),
            ),
            padding,
            parentSafeArea: parentSafeArea,
          );
          final back = find.byKey(const ValueKey('back'));
          final action = find.byKey(const ValueKey('action'));
          expectInsideSafeWidth(tester, back, padding);
          expectInsideSafeWidth(tester, action, padding);
          // The design margin is scaled; hardware insets must remain unscaled
          // and must only be applied once, including with a parent SafeArea.
          expect(tester.getRect(back).left, closeTo(padding.left + 9.6, 0.01));
          expect(
            tester.getRect(action).right,
            closeTo(size.width - padding.right - 9.6, 0.01),
          );
          expect(
            tester.getSize(find.byType(PageHeader)).height,
            padding.top + 48,
          );
          if (!parentSafeArea) {
            expect(tester.getSize(find.byType(PageHeader)).width, size.width);
          }
          await tester.tap(back);
          await tester.tap(action);
          expect(tester.takeException(), isNull);
        }
        expect(backTaps, insets.length);
        expect(actionTaps, insets.length);
      },
    );

    testWidgets(
      'dashboard profile and bell stay inside horizontal safe area ($parentSafeArea)',
      (tester) async {
        var profileTaps = 0;
        var notificationTaps = 0;
        for (final padding in insets) {
          await pumpHeader(
            tester,
            DashboardHeaderBar(
              topInset: padding.top,
              name: 'Nguyễn Minh Anh',
              profile: null,
              role: ProfileRole.parent,
              canSwitchProfile: true,
              isProfileMenuOpen: false,
              parentStreakCount: 1,
              onProfileTap: () => profileTaps++,
              onNotificationTap: () => notificationTaps++,
            ),
            padding,
            parentSafeArea: parentSafeArea,
          );
          final avatar = find.byType(DashboardProfileAvatar);
          final bell = find.byType(DashboardNotificationButton);
          expectInsideSafeWidth(tester, avatar, padding);
          expectInsideSafeWidth(tester, bell, padding);
          expect(tester.getRect(avatar).left, padding.left + 14);
          expect(tester.getRect(bell).right, size.width - padding.right - 14);
          expect(
            tester.getSize(find.byType(DashboardHeaderBar)).height,
            padding.top + 64,
          );
          if (!parentSafeArea) {
            expect(
              tester.getSize(find.byType(DashboardHeaderBar)).width,
              size.width,
            );
          }
          await tester.tap(avatar);
          await tester.tap(bell);
          expect(tester.takeException(), isNull);
        }
        expect(profileTaps, insets.length);
        expect(notificationTaps, insets.length);
      },
    );

    testWidgets(
      'teacher header avoids both camera sides without double padding ($parentSafeArea)',
      (tester) async {
        var notificationTaps = 0;
        for (final padding in insets) {
          await pumpHeader(
            tester,
            TeacherTopBar(
              profile: null,
              topPadding: padding.top,
              onNotificationTap: () => notificationTaps++,
            ),
            padding,
            parentSafeArea: parentSafeArea,
          );
          final avatar = find.byType(ProfileAvatarImage);
          final bell = find.byType(InkWell);
          expectInsideSafeWidth(tester, avatar, padding);
          expectInsideSafeWidth(tester, bell, padding);
          expect(tester.getRect(avatar).left, padding.left + 18);
          expect(tester.getRect(bell).right, size.width - padding.right - 18);
          if (!parentSafeArea) {
            expect(
              tester.getSize(find.byType(TeacherTopBar)).width,
              size.width,
            );
          }
          await tester.tap(bell);
          expect(tester.takeException(), isNull);
        }
        expect(notificationTaps, insets.length);
      },
    );
  }
}
