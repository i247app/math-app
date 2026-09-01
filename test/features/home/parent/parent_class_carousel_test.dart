import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/home/presentation/parent/models/parent_child_summary.dart';
import 'package:numi/features/home/presentation/parent/widgets/parent_class_carousel.dart';

void main() {
  testWidgets('hides children who have not joined a class', (tester) async {
    const summaries = <ParentChildSummary>[
      ParentChildSummary(profile: StudentProfile(name: 'Chưa có lớp')),
      ParentChildSummary(
        profile: StudentProfile(name: 'An'),
        classroom: ClassroomModel(name: '2A5', teacherName: 'Thầy An'),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox(
            width: 332,
            child: ParentClassCarousel(summaries: summaries, onTap: _noOp),
          ),
        ),
      ),
    );

    expect(find.text('CHƯA CÓ LỚP'), findsNothing);
    expect(find.text('AN'), findsOneWidget);
    expect(find.text('2A5'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('parent-class-card-0'))).width,
      332,
    );
  });

  testWidgets('hides the class list when no child has joined a class', (
    tester,
  ) async {
    const summaries = <ParentChildSummary>[
      ParentChildSummary(profile: StudentProfile(name: 'An')),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: ParentClassCarousel(summaries: summaries, onTap: _noOp),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('parent-class-card-0')), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('uses the full available width when there is only one class', (
    tester,
  ) async {
    const availableWidth = 332.0;
    const summary = ParentChildSummary(
      profile: StudentProfile(name: 'An'),
      classroom: ClassroomModel(name: '2A5', teacherName: 'Thầy An'),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox(
            width: availableWidth,
            child: ParentClassCarousel(summaries: [summary], onTap: _noOp),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('parent-class-card-0'))).width,
      availableWidth,
    );
    expect(find.byType(ListView), findsNothing);
    expect(find.byKey(const ValueKey('parent-class-page-dot-0')), findsNothing);
  });

  testWidgets('fits exactly two classes side by side without a carousel', (
    tester,
  ) async {
    const availableWidth = 332.0;
    const gap = 16.0;
    const summaries = <ParentChildSummary>[
      ParentChildSummary(
        profile: StudentProfile(name: 'An'),
        classroom: ClassroomModel(name: '2A5', teacherName: 'Thầy An'),
        classrooms: [
          ClassroomModel(name: '2A5', teacherName: 'Thầy An'),
          ClassroomModel(name: '3B1', teacherName: 'Cô Ngân'),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: SizedBox(
            width: availableWidth,
            child: ParentClassCarousel(summaries: summaries, onTap: _noOp),
          ),
        ),
      ),
    );

    const expectedCardWidth = (availableWidth - gap) / 2;
    expect(
      tester.getSize(find.byKey(const ValueKey('parent-class-card-0'))).width,
      expectedCardWidth,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('parent-class-card-1'))).width,
      expectedCardWidth,
    );
    expect(find.text('2A5'), findsOneWidget);
    expect(find.text('3B1'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byKey(const ValueKey('parent-class-page-dot-0')), findsNothing);
  });

  testWidgets('shows all parent classes with alternating brand colors', (
    tester,
  ) async {
    var tapCount = 0;
    const summaries = <ParentChildSummary>[
      ParentChildSummary(
        profile: StudentProfile(name: 'An'),
        classroom: ClassroomModel(name: '2A5', teacherName: 'Thầy An'),
      ),
      ParentChildSummary(
        profile: StudentProfile(name: 'Bình'),
        classroom: ClassroomModel(name: '3B1', teacherName: 'Cô Ngân'),
      ),
      ParentChildSummary(
        profile: StudentProfile(name: 'Chi'),
        classroom: ClassroomModel(name: '4C2', teacherName: 'Cô Mai'),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: SizedBox(
            width: 332,
            child: ParentClassCarousel(
              summaries: summaries,
              onTap: () => tapCount++,
            ),
          ),
        ),
      ),
    );

    expect(find.text('AN'), findsOneWidget);
    expect(find.text('2A5'), findsOneWidget);
    expect(find.text('BÌNH'), findsOneWidget);
    expect(find.text('3B1'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('parent-class-page-dot-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('parent-class-page-dot-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('parent-class-page-dot-2')),
      findsOneWidget,
    );

    final tealCard = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('parent-class-card-0')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final orangeCard = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey('parent-class-card-1')),
        matching: find.byType(DecoratedBox),
      ),
    );

    expect((tealCard.decoration as BoxDecoration).color, AppColors.brandTeal);
    expect(
      (orangeCard.decoration as BoxDecoration).color,
      AppColors.brandOrange,
    );

    await tester.tap(find.text('2A5'));
    expect(tapCount, 1);
  });
}

void _noOp() {}
