import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/home/widgets/parent/parent_home_action_button.dart';

void main() {
  testWidgets('Vietnamese home actions show both lines without truncation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 360.0]) {
      for (final textScale in [1.0, 1.4]) {
        tester.view.physicalSize = Size(width, 700);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: ParentHomeActionButton(
                          label: 'Đánh Giá\nTrình Độ',
                          iconAsset:
                              'assets/icons/home-assessment-stopwatch.png',
                          colors: const [Color(0xFFFFBE54), Color(0xFFFF993C)],
                          accentColor: const Color(0xFFFFDB70),
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ParentHomeActionButton(
                          label: 'Học Và\nLuyện Tập',
                          iconAsset: 'assets/icons/home-learning-book.png',
                          colors: const [Color(0xFFFFA18C), Color(0xFFFA796B)],
                          accentColor: const Color(0xFFFFB0AA),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final label in ['Đánh Giá\nTrình Độ', 'Học Và\nLuyện Tập']) {
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text(label),
          );
          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: '$label at width $width, text scale $textScale',
          );
        }
        expect(tester.takeException(), isNull);
      }
    }
  });
}
