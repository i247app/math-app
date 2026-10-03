import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_weak_topics_card.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final dark in [false, true]) {
    for (final language in [AppLanguage.vi, AppLanguage.en]) {
      testWidgets('weak topics fit narrow layout ($dark, $language)', (
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
        var taps = 0;
        await tester.pumpWidget(
          LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: ExamReviewWeakTopicsCard(
                        onOpenAiReview: () => taps++,
                        topics: const [
                          ExamPracticeTopic(
                            topic: ' Phép cộng và phép trừ trong phạm vi 100 ',
                            answered: 3,
                            wrong: 2,
                          ),
                          ExamPracticeTopic(topic: '  ', answered: 1, wrong: 1),
                          ExamPracticeTopic(
                            topic: 'Toán đố',
                            answered: 0,
                            wrong: 0,
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
        expect(
          find.text('Phép cộng và phép trừ trong phạm vi 100, Toán đố'),
          findsOneWidget,
        );
        expect(find.text('-'), findsNothing);
        expect(find.byType(Divider), findsNothing);
        expect(find.text('  '), findsNothing);
        expect(
          find.text(
            language == AppLanguage.vi
                ? '2/3 câu trả lời sai'
                : '2/3 incorrect answers',
          ),
          findsNothing,
        );
        expect(
          find.text(language == AppLanguage.vi ? 'Nhận Xét' : 'Review'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.auto_stories_outlined), findsNothing);
        final button = find.byKey(const ValueKey('exam-review-open-text'));
        expect(tester.getSize(button), const Size(48, 48));
        final icon = tester.widget<Icon>(
          find.byIcon(Icons.chevron_right_rounded),
        );
        final cardContext = tester.element(
          find.byType(ExamReviewWeakTopicsCard),
        );
        expect(icon.color, cardContext.themeColors.textMuted);
        expect(icon.size, 32);
        expect(
          tester.getCenter(button).dx,
          greaterThan(
            tester
                .getCenter(
                  find.text('Phép cộng và phép trừ trong phạm vi 100, Toán đố'),
                )
                .dx,
          ),
        );
        await tester.ensureVisible(button);
        await tester.tap(button);
        expect(taps, 1);
        expect(tester.takeException(), isNull);

        const aiText =
            'Bé làm tốt đếm, ghép số, phân loại và sắp xếp. '
            'Ba mẹ nên luyện thêm cộng trừ, so sánh số và quy luật lặp lại '
            'bằng đồ vật quen thuộc.';
        await tester.pumpWidget(
          LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(13),
                      child: ExamReviewWeakTopicsCard(
                        topics: [],
                        aiReviewShort: aiText,
                        onOpenAiReview: () => taps++,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text(aiText), findsOneWidget);
        expect(find.byIcon(Icons.auto_stories_outlined), findsNothing);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
        expect(
          find.text(language == AppLanguage.vi ? 'Nhận Xét' : 'Review'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('weak topic box is hidden for empty or blank topics', (
    tester,
  ) async {
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    for (final topics in [
      const <ExamPracticeTopic>[],
      const [ExamPracticeTopic(topic: ' ', answered: 1, wrong: 1)],
    ]) {
      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: ExamReviewWeakTopicsCard(topics: topics)),
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('exam-review-weak-topics-card')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
