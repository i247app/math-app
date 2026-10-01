import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/controllers/exam_review_controller.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_grade_level_badge.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_practice_banner.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  for (final language in AppLanguage.values) {
    for (final dark in [false, true]) {
      for (final viewport in [
        (width: 390.0, scale: 1.0),
        (width: 280.0, scale: 2.0),
      ]) {
        testWidgets(
          'AI description sits below badge without empty space ($language, $dark, $viewport)',
          (tester) async {
            await tester.binding.setSurfaceSize(Size(viewport.width, 844));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            final originalLanguage = AppLanguageState.current;
            final lingo = LingoProvider();
            addTearDown(() {
              AppLanguageState.current = originalLanguage;
              lingo.dispose();
            });
            await lingo.setLanguage(language);
            Future<void> pump(String? shortText) async {
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
                        body: ExamReviewContent(
                          exam: const GeneratedExam(
                            grade: 3,
                            level: 4,
                            questions: [],
                          ),
                          selectedIndex: 0,
                          mode: ExamReviewMode.result,
                          allowRetry: false,
                          showTime: false,
                          isLoading: false,
                          errorMessage: null,
                          onRetry: () {},
                          onModeSelected: (_) {},
                          onQuestionSelected: (_) {},
                          submittedAnswers: const {},
                          retryAnswers: const {},
                          onAnswerSelected: (_, _) {},
                          onPrevious: () {},
                          onNext: () {},
                          onPractice: () {},
                          aiShortText: shortText,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
            }

            final banner = find.byKey(
              const ValueKey('exam-review-practice-banner'),
            );
            final description = find.byKey(
              const ValueKey('exam-review-ai-short-text'),
            );
            await pump(null);
            final emptyBannerTop = tester.getTopLeft(banner).dy;
            const text =
                'Practice addition, subtraction, number comparisons and repeating patterns with familiar objects.';
            await pump('  $text  ');
            expect(tester.widget<Text>(description).data, text);
            final badgeText = find.descendant(
              of: find.byType(ExamReviewGradeLevelBadge),
              matching: find.byType(Text),
            );
            expect(
              tester.widget<Text>(description).style?.fontSize,
              tester.widget<Text>(badgeText).style?.fontSize,
            );
            expect(
              tester.getTopLeft(description).dy,
              greaterThanOrEqualTo(tester.getBottomLeft(badgeText).dy),
            );
            expect(
              tester.getBottomLeft(description).dy,
              lessThan(tester.getTopLeft(banner).dy),
            );
            expect(
              find.descendant(
                of: find.byType(ExamReviewPracticeBanner),
                matching: description,
              ),
              findsNothing,
            );
            expect(tester.getTopLeft(banner).dy, greaterThan(emptyBannerTop));
            expect(tester.takeException(), isNull);
            for (final empty in [null, '', ' \n ']) {
              await pump(empty);
              expect(description, findsNothing);
              expect(tester.getTopLeft(banner).dy, emptyBannerTop);
              expect(tester.takeException(), isNull);
            }
          },
        );
      }
    }
  }
}
