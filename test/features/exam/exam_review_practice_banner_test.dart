import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_grade_level_badge.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_practice_banner.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final language in [AppLanguage.vi, AppLanguage.en]) {
    for (final dark in [false, true]) {
      for (final viewport in [
        (width: 390.0, scale: 1.0),
        (width: 280.0, scale: 2.0),
      ]) {
        testWidgets('practice banner fits $language, dark=$dark, $viewport', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(viewport.width, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final originalLanguage = AppLanguageState.current;
          final lingo = LingoProvider();
          addTearDown(() {
            AppLanguageState.current = originalLanguage;
            lingo.dispose();
          });
          await lingo.setLanguage(language);
          var taps = 0;
          await tester.pumpWidget(
            LingoScope(
              lingo: lingo,
              child: MaterialApp(
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                home: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(viewport.scale),
                  ),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ExamReviewGradeLevelBadge(grade: 3, level: 4),
                            const SizedBox(height: 10),
                            ExamReviewPracticeBanner(
                              onTap: () => taps++,
                              aiShortText:
                                  'Luyện thêm cộng trừ, so sánh số và quy luật '
                                  'lặp lại bằng đồ vật quen thuộc.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(
              language == AppLanguage.vi
                  ? 'Lớp 3 - Level 4'
                  : 'Grade 3 - Level 4',
            ),
            findsOneWidget,
          );
          expect(find.text('AI LEARING'), findsOneWidget);
          expect(
            find.text(
              'Luyện thêm cộng trừ, so sánh số và quy luật '
              'lặp lại bằng đồ vật quen thuộc.',
            ),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
          expect(
            (tester.widget<Image>(find.byType(Image)).image as ResizeImage)
                .imageProvider,
            const AssetImage('assets/images/review-practice-mascot.png'),
          );
          expect(
            tester
                .getRect(
                  find.byKey(const ValueKey('exam-review-practice-action')),
                )
                .overlaps(tester.getRect(find.byType(Image))),
            isFalse,
          );
          await tester.tap(
            find.byKey(const ValueKey('exam-review-practice-action')),
          );
          expect(taps, 1);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('loading practice banner disables taps', (tester) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var taps = 0;
    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: ExamReviewPracticeBanner(
              isLoading: true,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('exam-review-practice-action')));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final shortText in [null, '', ' \n ']) {
    testWidgets('empty AI description has no default subtitle ($shortText)', (
      tester,
    ) async {
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ExamReviewPracticeBanner(
                onTap: () {},
                aiShortText: shortText,
              ),
            ),
          ),
        ),
      );
      expect(find.text('AI LEARING'), findsOneWidget);
      expect(find.text('Chọn đáp án đúng.'), findsNothing);
      expect(find.text('Choose the correct answer.'), findsNothing);
      expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kindergarten and level zero badge are localized', (
    tester,
  ) async {
    final originalLanguage = AppLanguageState.current;
    final lingo = LingoProvider();
    addTearDown(() {
      AppLanguageState.current = originalLanguage;
      lingo.dispose();
    });
    for (final language in [AppLanguage.vi, AppLanguage.en]) {
      await lingo.setLanguage(language);
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: ExamReviewGradeLevelBadge(grade: 0, level: 0),
            ),
          ),
        ),
      );
      expect(
        find.text(
          language == AppLanguage.vi
              ? 'Mẫu giáo - Level 0'
              : 'Kindergarten - Level 0',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
