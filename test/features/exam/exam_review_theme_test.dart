import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/exam/controllers/review_detail_controller.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_answer_tile.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_loading_content.dart';
import 'package:numi/features/exam/widgets/exam_review/exam_review_weak_topics_card.dart';
import 'package:numi/shared/widgets/option_bottom_sheet_shell.dart';
import 'package:numi/shared/widgets/settings_action_card.dart';

const _exam = GeneratedExam(
  examId: 10,
  grade: 2,
  level: 3,
  questions: [
    ExamQuestion(
      questionNumber: 1,
      questionName: '1 + 2 = ?',
      correctAnswer: 'A',
      answers: [
        ExamAnswer(label: 'A', content: '3'),
        ExamAnswer(label: 'B', content: '4'),
      ],
    ),
  ],
);

void main() {
  setUpAll(() async {
    final loader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await loader.load();
  });
  late LingoProvider lingo;
  setUp(() => lingo = LingoProvider());
  tearDown(() => lingo.dispose());
  Widget app(
    Widget child, {
    bool dark = false,
    double scale = 1,
    ThemeData? theme,
  }) => LingoScope(
    lingo: lingo,
    child: MaterialApp(
      theme: theme ?? (dark ? AppTheme.dark() : AppTheme.light()),
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: true,
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(body: child),
      ),
    ),
  );

  for (final dark in [false, true]) {
    testWidgets(
      'review answers use theme surfaces and foregrounds, dark=$dark',
      (tester) async {
        final colors = dark ? AppThemeColors.dark : AppThemeColors.light;
        Future<void> answer(String? selected) => tester.pumpWidget(
          app(
            ExamReviewAnswerTile(
              answer: _exam.questions.single.answers.first,
              selectedLabel: selected,
              correctLabel: 'B',
              showCorrectAnswer: true,
            ),
            dark: dark,
          ),
        );
        await answer(null);
        expect(
          (tester
                      .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                      .decoration!
                  as BoxDecoration)
              .color,
          colors.elevatedSurface,
        );
        expect(
          tester.widget<Text>(find.text('3')).style!.color,
          colors.textPrimary,
        );
        await answer('A');
        await tester.pumpAndSettle();
        expect(
          (tester
                      .widget<AnimatedContainer>(find.byType(AnimatedContainer))
                      .decoration!
                  as BoxDecoration)
              .color,
          colors.errorSurface,
        );
        expect(tester.widget<Text>(find.text('3')).style!.color, colors.error);
        expect(
          tester.widget<Icon>(find.byIcon(Icons.close_rounded)).color,
          colors.onError,
        );
      },
    );

    for (final mode in [ExamReviewMode.result, ExamReviewMode.retry]) {
      for (final narrow in [false, true]) {
        testWidgets('review content fits theme=$dark mode=$mode narrow=$narrow', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(narrow ? 280 : 390, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final boundary = GlobalKey();
          await tester.pumpWidget(
            app(
              _previewBoundary(
                key: boundary,
                dark: dark,
                child: ExamReviewContent(
                  exam: _exam,
                  selectedIndex: 0,
                  mode: mode,
                  allowRetry: true,
                  isLoading: false,
                  errorMessage: null,
                  onRetry: () {},
                  onModeSelected: (_) {},
                  onQuestionSelected: (_) {},
                  submittedAnswers: const {1: 'B'},
                  retryAnswers: const {1: 'A'},
                  onAnswerSelected: (_, _) {},
                  onPrevious: () {},
                  onNext: () {},
                  onPractice: () {},
                  aiTitle: 'Numbers and arithmetic',
                  aiShortText: 'Practice adding and subtracting.',
                  aiReviewShort: 'Review addition and comparing numbers.',
                ),
              ),
              dark: dark,
              scale: narrow ? 2 : 1,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('WRITE_THEME_PREVIEWS')) {
            await _savePreview(
              tester,
              boundary,
              'review-${dark ? 'dark' : 'light'}-${mode.name}${narrow ? '-large-text' : ''}',
            );
          }
        });
      }
    }

    testWidgets('option sheet defaults follow the theme, dark=$dark', (
      tester,
    ) async {
      final colors = dark ? AppThemeColors.dark : AppThemeColors.light;
      await tester.pumpWidget(
        app(
          OptionBottomSheetShell(
            children: [
              OptionBottomSheetList(
                itemCount: 2,
                itemBuilder: (_, index) => Text('Option $index'),
              ),
            ],
          ),
          dark: dark,
        ),
      );
      final shell = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(OptionBottomSheetShell),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = shell.decoration! as BoxDecoration;
      expect(decoration.color, colors.elevatedSurface);
      expect(decoration.boxShadow!.single.color, colors.shadow);
      expect(tester.widget<Divider>(find.byType(Divider)).color, colors.border);
    });

    testWidgets('loading preview fits theme=$dark', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundary = GlobalKey();
      await tester.pumpWidget(
        app(
          _previewBoundary(
            key: boundary,
            dark: dark,
            child: const ExamReviewLoadingContent(),
          ),
          dark: dark,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('WRITE_THEME_PREVIEWS')) {
        await _savePreview(
          tester,
          boundary,
          'review-${dark ? 'dark' : 'light'}-loading',
        );
      }
    });
  }

  testWidgets('review and settings inherit the configured font family', (
    tester,
  ) async {
    final base = AppTheme.light();
    final theme = base.copyWith(
      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge!.copyWith(
          fontFamily: 'CustomAppFont',
        ),
      ),
    );
    await tester.pumpWidget(
      app(
        Column(
          children: [
            const ExamReviewWeakTopicsCard(
              topics: [],
              aiReviewShort: 'Feedback',
            ),
            SettingsActionCard(
              icon: Icons.settings,
              iconColor: Colors.teal,
              iconBackground: Colors.transparent,
              title: 'Settings',
              subtitle: 'Description',
              onTap: () {},
            ),
          ],
        ),
        theme: theme,
      ),
    );
    for (final label in ['Feedback', 'Settings', 'Description']) {
      expect(
        tester.widget<Text>(find.text(label)).style!.fontFamily,
        'CustomAppFont',
      );
    }
  });
}

Future<void> _savePreview(
  WidgetTester tester,
  GlobalKey key,
  String name,
) async {
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/images/review-practice-mascot.png'),
      key.currentContext!,
    ),
  );
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final output = File('.dart_tool/theme-previews/$name.png');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Widget _previewBoundary({
  required GlobalKey key,
  required bool dark,
  required Widget child,
}) => RepaintBoundary(
  key: key,
  child: ColoredBox(
    color: (dark ? AppThemeColors.dark : AppThemeColors.light).pageBackground,
    child: child,
  ),
);
