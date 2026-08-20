import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/presentation/screens/parent_message_contacts_screen.dart';
import 'package:numi/features/classroom/widgets/parent_messages/parent_message_contact_list_tile.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  testWidgets('shows online and offline contacts and supports search', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ParentMessageContactsScreen(
            primaryTeacherName: 'Cô Lan Hương',
          ),
        ),
      ),
    );

    expect(find.byType(PageHeader), findsOneWidget);
    expect(find.text('Danh Sách'), findsOneWidget);
    expect(find.byType(ParentMessageContactListTile), findsNWidgets(7));
    expect(find.text('Đang hoạt động'), findsNWidgets(4));

    await tester.enterText(find.byType(TextField), 'Tuyết Mai');
    await tester.pump();

    expect(find.byType(ParentMessageContactListTile), findsOneWidget);
    expect(find.text('ONLINE'), findsNothing);
    expect(find.text('OFFLINE'), findsOneWidget);
    expect(find.text('Cô Tuyết Mai'), findsOneWidget);
  });
}
