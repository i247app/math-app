import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/models/parent_room_entry.dart';
import 'package:numi/features/classroom/widgets/parent_room/parent_room_class_grid.dart';

void main() {
  testWidgets('renders room classes in a two-column four-color grid', (
    tester,
  ) async {
    ParentRoomEntry? openedEntry;
    final entries = <ParentRoomEntry>[
      _entry(1, '2A5'),
      _entry(2, '3B1'),
      _entry(3, '4C2'),
      _entry(4, '5D3'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 332,
            child: ParentRoomClassGrid(
              entries: entries,
              onOpen: (entry) => openedEntry = entry,
            ),
          ),
        ),
      ),
    );

    final first = find.byKey(const ValueKey('parent-room-class-card-0'));
    final second = find.byKey(const ValueKey('parent-room-class-card-1'));
    final third = find.byKey(const ValueKey('parent-room-class-card-2'));
    final fourth = find.byKey(const ValueKey('parent-room-class-card-3'));

    expect(tester.getSize(first), const Size(160, 160));
    expect(tester.getSize(second), const Size(160, 160));
    expect(tester.getTopLeft(first).dy, tester.getTopLeft(second).dy);
    expect(
      tester.getTopLeft(third).dy,
      greaterThan(tester.getTopLeft(first).dy),
    );
    expect(_cardColor(tester, first), AppColors.brandTeal);
    expect(_cardColor(tester, second), AppColors.brandOrange);
    expect(_cardColor(tester, third), const Color(0xFF8A008C));
    expect(_cardColor(tester, fourth), const Color(0xFFFFB400));

    await tester.tap(second);
    expect(openedEntry, same(entries[1]));
  });
}

ParentRoomEntry _entry(int id, String name) {
  return ParentRoomEntry(
    child: StudentProfile(id: id, name: 'Bé $id'),
    layoutClassroom: HomeLayoutClassroom(
      memberProfileId: id,
      classroom: ClassroomModel(
        classroomId: id,
        name: name,
        teacherName: 'Thầy An',
      ),
    ),
  );
}

Color? _cardColor(WidgetTester tester, Finder card) {
  final decoration = tester.widget<DecoratedBox>(
    find.descendant(of: card, matching: find.byType(DecoratedBox)),
  );
  return (decoration.decoration as BoxDecoration).color;
}
