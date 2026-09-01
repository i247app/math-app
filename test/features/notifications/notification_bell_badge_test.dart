import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/home/teacher/home/widgets/teacher_top_bar.dart';
import 'package:numi/shared/widgets/notification_unread_dot.dart';

void main() {
  testWidgets('student and parent bell shows the unread dot', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: DashboardNotificationButton(
              onTap: () {},
              hasUnreadNotifications: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(notificationUnreadDotKey), findsOneWidget);
  });

  testWidgets('teacher bell hides the unread dot when there is no message', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LingoScope(
          lingo: lingo,
          child: Scaffold(
            body: TeacherTopBar(
              profile: null,
              topPadding: 0,
              onNotificationTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(notificationUnreadDotKey), findsNothing);
  });

  testWidgets('teacher bell shows the unread dot when a message exists', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LingoScope(
          lingo: lingo,
          child: Scaffold(
            body: TeacherTopBar(
              profile: null,
              topPadding: 0,
              onNotificationTap: () {},
              hasUnreadNotifications: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(notificationUnreadDotKey), findsOneWidget);
  });
}
