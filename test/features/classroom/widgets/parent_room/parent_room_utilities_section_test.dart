import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/presentation/widgets/parent_room/parent_room_utilities_section.dart';
import 'package:numi/shared/widgets/app_content_section.dart';

void main() {
  testWidgets('shows the six parent room features in a three-column grid', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var messageTapCount = 0;
    var membersTapCount = 0;
    var utilityTapCount = 0;

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: ParentRoomUtilitiesSection(
                onMessageTap: () => messageTapCount++,
                onMembersTap: () => membersTapCount++,
                onUtilityTap: () => utilityTapCount++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Tính năng'), findsOneWidget);
    expect(find.text('Tin nhắn'), findsOneWidget);
    expect(find.text('Bài Tập'), findsOneWidget);
    expect(find.text('Kiểm Tra'), findsOneWidget);
    expect(find.text('Tài Liệu'), findsOneWidget);
    expect(find.text('Tiến độ'), findsOneWidget);
    expect(find.text('Thành viên'), findsOneWidget);
    expect(find.byType(AppContentSection), findsNothing);

    final first = find.byKey(const ValueKey('parent-room-utility-message'));
    final fourth = find.byKey(const ValueKey('parent-room-utility-document'));
    expect(tester.getTopLeft(first).dx, 0);
    expect(tester.getTopLeft(first).dy, lessThan(tester.getTopLeft(fourth).dy));

    final shadowBox = tester.widget<DecoratedBox>(
      find.descendant(of: first, matching: find.byType(DecoratedBox)).first,
    );
    final decoration = shadowBox.decoration as BoxDecoration;
    expect(decoration.boxShadow!.single.blurRadius, 12);
    expect(decoration.boxShadow!.single.offset, const Offset(0, 4));

    final tileInk = tester.widget<Ink>(
      find.descendant(of: first, matching: find.byType(Ink)),
    );
    final inkDecoration = tileInk.decoration! as BoxDecoration;
    expect(inkDecoration.boxShadow, isNull);

    await tester.tap(first);
    expect(messageTapCount, 1);
    expect(utilityTapCount, 0);

    await tester.tap(find.byKey(const ValueKey('parent-room-utility-members')));
    expect(membersTapCount, 1);
    expect(utilityTapCount, 0);
  });
}
