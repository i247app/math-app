import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/notifications/application/controllers/notification_state.dart';
import 'package:numi/features/notifications/presentation/widgets/notification_card.dart';
import 'package:numi/features/notifications/presentation/widgets/notification_content.dart';

void main() {
  testWidgets('shows the child-profile reminder in Notification screen', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var createTaps = 0;

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: NotificationContent(
              state: const NotificationState(isLoading: false, hasLoaded: true),
              onRetry: () {},
              onRefresh: () async {},
              showMissingChildProfileNotice: true,
              onCreateChildProfile: () => createTaps++,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(MissingChildProfileNotificationCard), findsOneWidget);
    expect(find.text('Chưa có hồ sơ'), findsOneWidget);

    await tester.tap(find.byType(MissingChildProfileNotificationCard));
    expect(createTaps, 1);
  });
}
