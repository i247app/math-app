import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/screens/teacher/teacher_home_tab.dart';
import 'package:numi/features/home/widgets/teacher/teacher_hero_card.dart';
import 'package:numi/features/home/widgets/teacher/teacher_home_hero_skeleton.dart';
import 'package:numi/shared/widgets/teacher_empty_assignments_panel.dart';
import 'package:numi/shared/widgets/settings_action_card.dart';
import 'package:numi/shared/widgets/app_section_header.dart';
import 'package:numi/core/animations/app_staggered_entrance.dart';

class _EmptyTeacherHomeService implements HomeLayoutService {
  const _EmptyTeacherHomeService();

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    return const HomeLayout(role: 'TEACHER');
  }
}

class _DeferredTeacherHomeService implements HomeLayoutService {
  final Completer<HomeLayout> completer = Completer<HomeLayout>();

  @override
  Future<HomeLayout> getLayout({required int profileId}) => completer.future;
}

void main() {
  testWidgets('starts teacher home entrance after initial loading completes', (
    tester,
  ) async {
    const profileId = 912346;
    HomeProfileCache.instance.invalidateProfile(profileId);
    addTearDown(() => HomeProfileCache.instance.invalidateProfile(profileId));

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    final homeService = _DeferredTeacherHomeService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LingoScope(
          lingo: lingo,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Scaffold(
              body: TeacherHomeTab(
                user: null,
                activeProfile: const StudentProfile(
                  profileId: profileId,
                  name: 'Teacher',
                  role: 'TEACHER',
                  profileStatus: 'ACTIVE',
                ),
                bottomPadding: 0,
                homeLayoutService: homeService,
                onCompleteProfile: () async {},
              ),
            ),
          ),
        ),
      ),
    );

    final loadingEntrance = find.ancestor(
      of: find.byType(TeacherHomeHeroSkeleton),
      matching: find.byType(AppStaggeredEntrance),
    );
    expect(loadingEntrance, findsNothing);

    homeService.completer.complete(const HomeLayout(role: 'TEACHER'));
    await tester.pump();

    final readyEntrance = find.ancestor(
      of: find.byType(TeacherHeroCard),
      matching: find.byType(AppStaggeredEntrance),
    );
    expect(readyEntrance, findsOneWidget);
    final readyEntranceState = tester.state(readyEntrance);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(readyEntrance, findsOneWidget);
    expect(tester.state(readyEntrance), same(readyEntranceState));
  });

  testWidgets(
    'shows the settings-style profile action below the teacher banner',
    (tester) async {
      const profileId = 912345;
      HomeProfileCache.instance.invalidateProfile(profileId);
      addTearDown(() => HomeProfileCache.instance.invalidateProfile(profileId));

      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      var completionTaps = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: LingoScope(
            lingo: lingo,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(390, 844),
                disableAnimations: true,
              ),
              child: Scaffold(
                body: TeacherHomeTab(
                  user: null,
                  activeProfile: const StudentProfile(
                    profileId: profileId,
                    name: 'Teacher',
                    role: 'TEACHER',
                    profileStatus: 'DRAFT',
                  ),
                  bottomPadding: 0,
                  homeLayoutService: const _EmptyTeacherHomeService(),
                  onCompleteProfile: () async => completionTaps++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final hero = find.byType(TeacherHeroCard);
      final profileAction = find.byType(SettingsActionCard);
      expect(hero, findsOneWidget);
      expect(profileAction, findsOneWidget);
      expect(find.text('Chưa có lớp học nào.'), findsOneWidget);
      final emptyStates = find.byType(TeacherEmptyAssignmentsPanel);
      expect(emptyStates, findsNWidgets(2));
      expect(
        tester.getSize(emptyStates.at(1)).width,
        tester.getSize(emptyStates.at(0)).width,
      );
      final sectionTitles = <String>['Lớp học của bạn', 'Bài tập vừa giao'];
      for (final title in sectionTitles) {
        final titleWidget = tester.widget<Text>(find.text(title));
        expect(titleWidget.style?.fontSize, FontSize.xl);
        expect(titleWidget.style?.fontWeight, FontWeight.w600);
      }
      final viewAllLabels = tester.widgetList<Text>(find.text('Xem tất cả'));
      expect(viewAllLabels, hasLength(2));
      for (final label in viewAllLabels) {
        expect(label.style?.fontSize, FontSize.caption);
        expect(label.style?.fontWeight, FontWeight.w800);
        expect(label.style?.decoration, isNull);
      }
      expect(
        find.descendant(
          of: find.byType(AppSectionHeader),
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: profileAction,
          matching: find.byIcon(Icons.person_outline_rounded),
        ),
        findsNothing,
      );
      expect(
        find.text('Hồ sơ chưa hoàn tất. Nhấn để bổ sung thông tin.'),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(profileAction).dy,
        greaterThan(tester.getBottomLeft(hero).dy),
      );

      await tester.tap(find.text('Hoàn Thành Hồ Sơ'));
      await tester.pump(const Duration(seconds: 1));
      expect(completionTaps, 1);
    },
  );
}
