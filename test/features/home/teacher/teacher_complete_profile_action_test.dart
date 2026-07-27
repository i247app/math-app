import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/home/teacher/home/teacher_home_tab.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_hero_card.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_no_class_panel.dart';
import 'package:numi/features/settings/widgets/menu/settings_action_card.dart';

class _EmptyTeacherHomeService implements HomeLayoutService {
  const _EmptyTeacherHomeService();

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    return const HomeLayout(role: 'TEACHER');
  }
}

void main() {
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
      expect(find.byType(TeacherNoClassPanel), findsNothing);
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
