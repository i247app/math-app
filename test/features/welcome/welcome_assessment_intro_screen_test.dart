import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/auth/models/guest_account.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/welcome/screens/welcome_assessment_intro_screen.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    FlutterSecureStorage.setMockInitialValues({});
  });

  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(800, 1024),
    Size(844, 390),
  ]) {
    for (final hasHistory in [false, true]) {
      testWidgets('fits $size with history=$hasHistory', (tester) async {
        final progress = Completer<ExamProgressResponse>();
        await _pumpIntro(tester, size: size, progress: progress.future);

        expect(
          find.byKey(
            const ValueKey('welcome-assessment-intro-history-skeleton'),
          ),
          findsOneWidget,
        );
        _expectBackVisible(tester);
        expect(tester.takeException(), isNull);

        progress.complete(_progress(hasHistory));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        _expectBackVisible(tester);
        final background = find.byKey(
          const ValueKey('welcome-assessment-intro-background'),
        );
        final backgroundRect = tester.getRect(background);
        final backTop = tester
            .getTopLeft(find.byKey(const ValueKey('welcome-assessment-back')))
            .dy;

        final visual = find.byKey(
          ValueKey(
            hasHistory
                ? 'welcome-assessment-intro-chart'
                : 'welcome-assessment-intro-mascot',
          ),
        );
        await tester.scrollUntilVisible(visual, 120, scrollable: _scrollable);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final ribbon = tester.getRect(
          find.byKey(
            const ValueKey('placement-grade-ribbon'),
            skipOffstage: false,
          ),
        );
        final visualRect = tester.getRect(visual);
        expect(visualRect.top, greaterThanOrEqualTo(ribbon.bottom));
        final viewportRect = tester.getRect(
          find.byKey(const ValueKey('welcome-assessment-intro-scroll')),
        );
        expect(visualRect.overlaps(viewportRect), isTrue);
        await tester.scrollUntilVisible(_action, 120, scrollable: _scrollable);
        await tester.pumpAndSettle();
        _expectStartVisible(tester, size);
        expect(tester.getRect(background), backgroundRect);
        if (tester.state<ScrollableState>(_scrollable).position.pixels > 0) {
          expect(
            tester
                .getTopLeft(
                  find.byKey(
                    const ValueKey('welcome-assessment-back'),
                    skipOffstage: false,
                  ),
                )
                .dy,
            lessThan(backTop),
          );
        }
      });
    }
  }

  for (final language in AppLanguage.values) {
    testWidgets('large text scrolls and assessment starts in $language', (
      tester,
    ) async {
      var starts = 0;
      final start = Completer<void>();
      const size = Size(320, 568);
      await _pumpIntro(
        tester,
        size: size,
        progress: Future.value(_progress(true)),
        language: language,
        textScale: 2,
        onAssessment: (_) {
          starts++;
          return start.future;
        },
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      _expectBackVisible(tester);

      final scroll = tester.state<ScrollableState>(_scrollable);
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('welcome-assessment-intro-chart')),
        120,
        scrollable: _scrollable,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<Text>(
              find.byKey(
                const ValueKey('placement-current-grade-label'),
                skipOffstage: false,
              ),
            )
            .data,
        language == AppLanguage.vi ? 'LỚP' : 'GRADE',
      );
      expect(
        find.text(language == AppLanguage.vi ? 'Trend' : 'Trend'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(_action, 120, scrollable: _scrollable);
      await tester.pumpAndSettle();
      _expectStartVisible(tester, size);
      await tester.tap(_action);
      await tester.pump();
      expect(starts, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(_action, warnIfMissed: false);
      expect(starts, 1);
      start.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

final _action = find.byKey(const ValueKey('welcome-assessment-intro-action'));
final _scrollable = find.descendant(
  of: find.byKey(const ValueKey('welcome-assessment-intro-scroll')),
  matching: find.byType(Scrollable),
);

void _expectBackVisible(WidgetTester tester) {
  final back = find.byKey(const ValueKey('welcome-assessment-back'));
  expect(back.hitTestable(), findsOneWidget);
  expect(tester.getRect(back).top, greaterThanOrEqualTo(24));
  expect(find.byKey(const ValueKey('welcome-assessment-skip')), findsNothing);
}

void _expectStartVisible(WidgetTester tester, Size size) {
  expect(
    tester.getSize(_action).width,
    closeTo(math.min(size.width - 112, 240), 0.1),
  );
  expect(tester.getSize(_action).height, greaterThanOrEqualTo(66));
  expect(_action.hitTestable(), findsOneWidget);
  final rect = tester.getRect(_action);
  expect(rect.top, greaterThanOrEqualTo(24));
  expect(rect.bottom, lessThanOrEqualTo(size.height - 32));
}

Future<void> _pumpIntro(
  WidgetTester tester, {
  required Size size,
  required Future<ExamProgressResponse> progress,
  AppLanguage language = AppLanguage.vi,
  double textScale = 1,
  Future<void> Function(BuildContext)? onAssessment,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 32);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final lingo = LingoProvider();
  await lingo.setLanguage(language);
  addTearDown(lingo.dispose);
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GuestAccountService>.value(
          value: _GuestAccountService(),
        ),
        RepositoryProvider<ExamService>.value(value: _ExamService(progress)),
      ],
      child: LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(extensions: const [AppThemeColors.light]),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: WelcomeAssessmentIntroScreen(
            onAssessment: onAssessment ?? (_) async {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

ExamProgressResponse _progress(bool hasHistory) => ExamProgressResponse(
  mstatus: 200,
  series: hasHistory
      ? [
          ExamProgressPoint(
            completedDt: DateTime(2026, 9, 26),
            correctNumber: 5,
            examId: 1,
            score: 5,
            scorePct: 50,
            sequence: 1,
            totalQuestions: 10,
            grade: 2,
            status: 'COMPLETE',
          ),
        ]
      : const [],
);

class _GuestAccountService implements GuestAccountService {
  @override
  GuestAccount get current =>
      const GuestAccount(uid: 1, user: {'profile_id': 1});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExamService implements ExamService {
  _ExamService(this.progress);

  final Future<ExamProgressResponse> progress;

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) => progress;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
