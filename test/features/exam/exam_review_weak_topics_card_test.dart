import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
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
        await tester.pumpWidget(
          LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: const MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(13),
                      child: ExamReviewWeakTopicsCard(
                        topics: [
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
          find.text(language == AppLanguage.vi ? 'Điểm yếu' : 'Weaknesses'),
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
