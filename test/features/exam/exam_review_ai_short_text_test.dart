import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/exam/controllers/review_detail_controller.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_content.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
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
          'Grade, AI title and description share plain styling in one box ($language, $dark, $viewport)',
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
            Future<void> pump(
              String? shortText, {
              String? aiTitle,
              int? grade = 3,
              int? level = 4,
            }) async {
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
                          exam: GeneratedExam(
                            grade: grade,
                            level: level,
                            questions: const [],
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
                          aiTitle: aiTitle,
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
            final title = find.byKey(const ValueKey('exam-review-ai-title'));
            final box = find.byKey(
              const ValueKey('exam-review-ai-description-box'),
            );
            final gradeText = find.byKey(
              const ValueKey('exam-review-grade-level-text'),
            );
            await pump(null);
            expect(box, findsOneWidget);
            expect(
              find.descendant(of: box, matching: gradeText),
              findsOneWidget,
            );
            expect(
              tester.widget<Text>(gradeText).data,
              language == AppLanguage.vi
                  ? 'Lớp 3 - Level 4'
                  : 'Grade 3 - Level 4',
            );
            final emptyBannerTop = tester.getTopLeft(banner).dy;
            const text =
                'Practice addition, subtraction, number comparisons and repeating patterns with familiar objects.';
            await pump('  $text  ');
            expect(title, findsNothing);
            expect(
              find.descendant(of: box, matching: description),
              findsOneWidget,
            );
            expect(tester.widget<Text>(description).data, text);
            expect(
              tester.widget<Text>(description).style,
              tester.widget<Text>(gradeText).style,
            );
            expect(
              tester.getTopLeft(description).dy,
              greaterThan(tester.getBottomLeft(gradeText).dy),
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
            const titleText = 'Numbers and arithmetic within 100';
            await pump('  $text  ', aiTitle: '  $titleText  ');
            expect(tester.widget<Text>(title).data, titleText);
            expect(tester.widget<Text>(description).data, text);
            expect(find.descendant(of: box, matching: title), findsOneWidget);
            expect(
              find.descendant(of: box, matching: gradeText),
              findsOneWidget,
            );
            expect(
              find.descendant(of: box, matching: description),
              findsOneWidget,
            );
            expect(
              tester.getBottomLeft(title).dy,
              lessThan(tester.getTopLeft(description).dy),
            );
            expect(
              tester.getBottomLeft(gradeText).dy,
              lessThan(tester.getTopLeft(title).dy),
            );
            for (final textFinder in [gradeText, title, description]) {
              final style = tester.widget<Text>(textFinder).style!;
              expect(style, tester.widget<Text>(gradeText).style);
              expect(style.fontWeight, FontWeight.w400);
              expect(
                style.color,
                dark ? AppThemeColors.dark.textPrimary : Colors.black,
              );
            }
            expect(
              find.descendant(of: box, matching: find.byType(Icon)),
              findsNothing,
            );
            expect(
              find.byKey(const ValueKey('exam-review-grade-level-badge')),
              findsNothing,
            );
            expect(
              tester.getBottomLeft(box).dy,
              lessThan(tester.getTopLeft(banner).dy),
            );
            expect(tester.takeException(), isNull);
            await pump(' \n ', aiTitle: titleText);
            expect(box, findsOneWidget);
            expect(title, findsOneWidget);
            expect(description, findsNothing);
            expect(tester.takeException(), isNull);
            for (final empty in [null, '', ' \n ']) {
              await pump(empty, aiTitle: empty);
              expect(box, findsOneWidget);
              expect(title, findsNothing);
              expect(description, findsNothing);
              expect(tester.getTopLeft(banner).dy, emptyBannerTop);
              expect(tester.takeException(), isNull);
            }
            await pump(null, grade: 0, level: 0);
            expect(
              tester.widget<Text>(gradeText).data,
              language == AppLanguage.vi
                  ? 'Mẫu giáo - Level 0'
                  : 'Kindergarten - Level 0',
            );
            await pump(null, grade: null, level: null);
            expect(box, findsNothing);
            expect(gradeText, findsNothing);
            await pump(text, aiTitle: titleText, grade: null, level: null);
            expect(box, findsOneWidget);
            expect(gradeText, findsNothing);
            expect(title, findsOneWidget);
            expect(description, findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
