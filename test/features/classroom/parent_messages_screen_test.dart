import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/presentation/screens/parent_messages_screen.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_preview_tile.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  testWidgets('uses the tab header and filters message previews', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ParentMessagesScreen(
            className: 'Lớp 2A1',
            teacherName: 'Cô Lan',
          ),
        ),
      ),
    );

    expect(find.byType(PageHeader), findsOneWidget);
    expect(find.text('Tin nhắn'), findsOneWidget);
    expect(find.byType(ParentMessagePreviewTile), findsNWidgets(5));
    expect(find.text('Lớp 2A1'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tuyết Mai');
    await tester.pump();

    expect(find.byType(ParentMessagePreviewTile), findsOneWidget);
    expect(find.text('Cô Tuyết Mai'), findsNWidgets(2));
  });
}
