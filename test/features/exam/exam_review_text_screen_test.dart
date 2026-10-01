import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/screens/exam_review_text_screen.dart';
import 'package:numi/shared/layouts/page_header.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final language in [AppLanguage.vi, AppLanguage.en]) {
    for (final dark in [false, true]) {
      testWidgets('long review scrolls below fixed header ($language, $dark)', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(280, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final originalLanguage = AppLanguageState.current;
        final lingo = LingoProvider();
        addTearDown(() {
          AppLanguageState.current = originalLanguage;
          lingo.dispose();
        });
        await lingo.setLanguage(language);
        final reviewText = List.filled(
          20,
          'Practice counting, addition and subtraction with familiar objects.',
        ).join('\n\n');
        await tester.pumpWidget(
          LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: child!,
              ),
              home: ExamReviewTextScreen(reviewText: reviewText),
            ),
          ),
        );
        final header = find.byType(PageHeader);
        final before = tester.getRect(header);
        expect(
          find.text(language == AppLanguage.vi ? 'Nhận Xét' : 'Review'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
        expect(
          tester.widget<SelectableText>(find.byType(SelectableText)).data,
          reviewText,
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        expect(scroll.position.pixels, greaterThan(0));
        expect(tester.getRect(header), before);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
