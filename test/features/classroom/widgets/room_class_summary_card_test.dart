import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/classroom/widgets/room_class_summary_card.dart';

void main() {
  testWidgets('renders the shared room class hierarchy and handles taps', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 360,
                child: RoomClassSummaryCard(
                  studentName: 'Yến Nhi',
                  className: '1A4',
                  teacherName: 'Thầy An',
                  backgroundColor: AppColors.brandTeal,
                  onTap: () => tapCount++,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('YẾN NHI'), findsOneWidget);
    expect(find.text('1A4'), findsOneWidget);
    expect(find.text('Thầy An'), findsOneWidget);
    expect(tester.getSize(find.byType(RoomClassSummaryCard)).height, 132);

    final decoration = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(RoomClassSummaryCard),
        matching: find.byType(DecoratedBox),
      ),
    );
    final boxDecoration = decoration.decoration as BoxDecoration;
    expect(boxDecoration.color, AppColors.brandTeal);
    expect(boxDecoration.borderRadius, BorderRadius.circular(28));

    await tester.tap(find.byType(RoomClassSummaryCard));
    expect(tapCount, 1);
  });
}
