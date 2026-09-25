import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/guest_account_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/models/guest_account.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/welcome/screens/welcome_assessment_intro_screen.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/session/controllers/app_session_cubit.dart';
import 'package:numi/features/session/controllers/app_session_state.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/main.dart';
import 'package:numi/shared/widgets/app_back_button.dart';

class _FakeAuthService implements AuthService {
  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FailingLoginLookupAuthService implements AuthService {
  @override
  Future<AuthLoginLookupResult> lookupLoginName(String loginName) {
    throw const AuthException('Service unavailable', status: 503);
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SignupLookupAuthService implements AuthService {
  _SignupLookupAuthService({this.accountExists = false});

  final bool accountExists;
  final List<String> lookedUpNames = <String>[];

  @override
  Future<AuthLoginLookupResult> lookupLoginName(String loginName) async {
    lookedUpNames.add(loginName);
    return AuthLoginLookupResult(
      loginName: loginName,
      exists: accountExists,
      user: accountExists ? LoginUser(id: 7, email: loginName) : null,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PendingExamService implements ExamService {
  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) => Completer<GeneratedExam>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IntroHistoryExamService implements ExamService {
  _IntroHistoryExamService({
    required this.stats,
    required this.progress,
    this.onGetProgress,
  });

  final List<ExamStats> stats;
  final ExamProgressResponse progress;
  final Future<ExamProgressResponse> Function(int call)? onGetProgress;
  int statsCalls = 0;
  int progressCalls = 0;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    expect(profileId, 421);
    expect(examType, examTypeAssessment);
    statsCalls++;
    return stats;
  }

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) async {
    expect(profileId, 421);
    expect(examType, examTypeAssessment);
    expect(toDt.difference(fromDt), const Duration(days: 7));
    progressCalls++;
    return await (onGetProgress?.call(progressCalls) ?? Future.value(progress));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGuestAccountService implements GuestAccountService {
  int ensureCalls = 0;

  final guest = const GuestAccount(
    uid: 42,
    user: <String, dynamic>{'uid': 42, 'profile_id': 421},
  );

  @override
  GuestAccount? get current => guest;

  @override
  Future<int?> readStoredUid() async => guest.uid;

  @override
  Future<GuestAccount> ensureGuest() async {
    ensureCalls++;
    return guest;
  }

  @override
  Future<void> clear() async {}
}

void main() {
  group('authentication entry characterization', () {
    testWidgets('starts on the welcome screen', (tester) async {
      await tester.pumpWidget(const NumiApp());

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
      expect(find.text('TEST YOUR SKILL'), findsOneWidget);
      expect(find.text('SIGN UP'), findsOneWidget);
      final assessment = find.byKey(
        const ValueKey('welcome-assessment-action'),
      );
      expect(
        find.descendant(
          of: assessment,
          matching: find.byIcon(Icons.timer_outlined),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: assessment,
          matching: find.byIcon(Icons.chevron_right_rounded),
        ),
        findsOneWidget,
      );
      expect(
        tester
            .widgetList<Material>(
              find.descendant(of: assessment, matching: find.byType(Material)),
            )
            .any((material) => material.color == const Color(0xFFF45D2D)),
        isTrue,
      );
      final assessmentMaterial = find.descendant(
        of: assessment,
        matching: find.byType(Material),
      );
      expect(tester.getSize(assessmentMaterial).width, lessThanOrEqualTo(264));
      expect(tester.getSize(assessmentMaterial).height, 60);
    });

    testWidgets('places assessment action 32 pixels above the books', (
      tester,
    ) async {
      await tester.pumpWidget(const NumiApp());

      final assessment = find.byKey(
        const ValueKey('welcome-assessment-action'),
      );
      final books = find.byKey(const ValueKey('welcome-books'));
      await tester.ensureVisible(assessment);

      expect(books, findsOneWidget);
      expect(
        tester.getTopLeft(books).dy - tester.getBottomLeft(assessment).dy,
        closeTo(32, 0.5),
      );
      expect(
        tester.getBottomLeft(books).dy,
        lessThan(tester.getTopLeft(find.text('SIGN UP')).dy),
      );
    });

    testWidgets('opens guest assessment from the initial welcome screen', (
      tester,
    ) async {
      final guestAccounts = _FakeGuestAccountService();
      await tester.pumpWidget(
        NumiApp(
          services: AppServices(
            examService: _PendingExamService(),
            guestAccountService: guestAccounts,
          ),
        ),
      );

      expect(guestAccounts.ensureCalls, 0);
      expect(
        tester.widget<Text>(find.text('SIGN UP')).style?.fontSize,
        FontSize.large,
      );
      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();

      expect(guestAccounts.ensureCalls, 1);
      expect(find.byType(WelcomeAssessmentIntroScreen), findsOneWidget);
      expect(find.text('TOÁN AI'), findsOneWidget);
      expect(find.text('Kiểm Tra Năng Lực'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(tester.widget<Text>(find.text('START')).style?.fontSize, 32);
      expect(
        tester.widget<Text>(find.text('TOÁN AI')).style?.fontFamily,
        'NunitoVariable',
      );
      expect(
        tester.widget<Text>(find.text('Kiểm Tra Năng Lực')).style?.fontFamily,
        'NunitoVariable',
      );

      await tester.tap(
        find.byKey(const ValueKey('welcome-assessment-intro-action')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AiAssessmentScreen), findsOneWidget);
    });

    testWidgets('returns from assessment intro to the initial welcome screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        NumiApp(
          services: AppServices(
            guestAccountService: _FakeGuestAccountService(),
            examService: _IntroHistoryExamService(
              stats: const <ExamStats>[],
              progress: const ExamProgressResponse(mstatus: 200),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeAssessmentIntroScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('welcome-assessment-back')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
      expect(find.byType(WelcomeAssessmentIntroScreen), findsNothing);
    });

    testWidgets('assessment intro keeps the mascot when progress is empty', (
      tester,
    ) async {
      final examService = _IntroHistoryExamService(
        stats: const <ExamStats>[
          ExamStats(
            correctNumber: 5,
            scorePercentage: 100,
            skippedNumber: 0,
            totalQuestions: 5,
            grade: 3,
          ),
        ],
        progress: const ExamProgressResponse(mstatus: 200),
      );
      await tester.pumpWidget(
        NumiApp(
          services: AppServices(
            guestAccountService: _FakeGuestAccountService(),
            examService: examService,
          ),
        ),
      );

      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('welcome-assessment-intro-mascot')),
        findsOneWidget,
      );
      expect(
        tester
            .getBottomLeft(find.byKey(const ValueKey('placement-grade-ribbon')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('welcome-assessment-intro-mascot')),
              )
              .dy,
        ),
      );
      expect(find.byType(AssessmentProgressionChart), findsNothing);
      expect(examService.statsCalls, 0);
      expect(examService.progressCalls, 1);
    });

    testWidgets('assessment intro shows journey chart without stats', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final examService = _IntroHistoryExamService(
        stats: const <ExamStats>[],
        progress: ExamProgressResponse(
          mstatus: 200,
          series: <ExamProgressPoint>[
            ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, 1),
              correctNumber: 5,
              examId: 1,
              score: 10,
              scorePct: 100,
              sequence: 1,
              totalQuestions: 5,
              grade: 1,
              status: 'COMPLETE',
            ),
            ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, 2),
              correctNumber: 5,
              examId: 2,
              score: 10,
              scorePct: 100,
              sequence: 2,
              totalQuestions: 5,
              grade: 3,
              status: 'COMPLETE',
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        NumiApp(
          services: AppServices(
            guestAccountService: _FakeGuestAccountService(),
            examService: examService,
          ),
        ),
      );

      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('welcome-assessment-intro-mascot')),
        findsNothing,
      );
      expect(
        tester
            .getBottomLeft(find.byKey(const ValueKey('placement-grade-ribbon')))
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('welcome-assessment-intro-chart')),
              )
              .dy,
        ),
      );
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.previousGrades, <int>[1]);
      expect(chart.finalGrade, 3);
      expect(chart.testNumbers, <int>[1, 2]);
      expect(chart.lastSubmittedAt, DateTime.utc(2026, 1, 2));
      expect(chart.maxVisiblePoints, 7);
      final currentGrade = find.byKey(
        const ValueKey('placement-progression-current-grade'),
      );
      expect(tester.widget<Text>(currentGrade).data, '3');
      expect(tester.widget<Text>(currentGrade).style?.fontSize, 72);
      expect(find.text('Trình độ'), findsNothing);
      expect(find.text('Level'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Level')).dy,
        lessThan(tester.getTopLeft(currentGrade).dy),
      );
      expect(
        tester.getCenter(find.text('Level')).dx,
        closeTo(tester.getCenter(currentGrade).dx, 1),
      );
      expect(
        tester
            .getRect(
              find.byKey(const ValueKey('welcome-assessment-intro-chart')),
            )
            .width,
        closeTo(328, 1),
      );
      final chartRect = tester.getRect(
        find.byKey(const ValueKey('placement-progression-chart')),
      );
      final ribbonRect = tester.getRect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
      );
      expect(ribbonRect.center.dx, closeTo(chartRect.center.dx, 1));
      expect(ribbonRect.width * 2028 / 2172, closeTo(chartRect.width, 1));
      final plotRect = tester.getRect(
        find.byKey(const ValueKey('placement-progression-plot')),
      );
      final gradeTickRect = tester.getRect(
        find.byKey(const ValueKey('placement-progression-tick-3')),
      );
      expect(plotRect.left - gradeTickRect.right, closeTo(12, 0.5));
      expect(plotRect.width, closeTo(chartRect.width - 200, 1));
      final submittedTimeRect = tester.getRect(
        find.byKey(const ValueKey('placement-progression-submitted-time')),
      );
      expect(submittedTimeRect.right, closeTo(chartRect.right - 19, 1));
      expect(examService.statsCalls, 0);
      expect(examService.progressCalls, 1);
    });

    testWidgets('assessment intro fits recent assessments without scrolling', (
      tester,
    ) async {
      final examService = _IntroHistoryExamService(
        stats: const <ExamStats>[],
        progress: ExamProgressResponse(
          mstatus: 200,
          series: List<ExamProgressPoint>.generate(7, (index) {
            final sequence = index + 1;
            return ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, sequence),
              correctNumber: 5,
              examId: sequence,
              score: 10,
              scorePct: 100,
              sequence: sequence,
              totalQuestions: 5,
              grade: sequence % 6,
              status: 'COMPLETE',
            );
          }),
        ),
      );
      await tester.pumpWidget(
        NumiApp(
          services: AppServices(
            guestAccountService: _FakeGuestAccountService(),
            examService: examService,
          ),
        ),
      );

      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();

      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.previousGrades, <int>[1, 2, 3, 4, 5, 0]);
      expect(chart.finalGrade, 1);
      expect(chart.testNumbers, <int>[1, 2, 3, 4, 5, 6, 7]);
      expect(chart.maxVisiblePoints, 7);
      expect(chart.lastSubmittedAt, DateTime.utc(2026, 1, 7));
      expect(find.text('Bài 1'), findsNothing);
      expect(find.text('Bài 7'), findsOneWidget);
      final scrollable = find.descendant(
        of: find.byKey(const ValueKey('welcome-assessment-intro-chart')),
        matching: find.byType(Scrollable),
      );
      expect(scrollable, findsNothing);
      final plot = tester.widget<CustomPaint>(
        find.byKey(const ValueKey('placement-progression-plot')),
      );
      expect((plot.painter as dynamic).points, hasLength(7));
      expect(examService.statsCalls, 0);
    });

    testWidgets('assessment intro waits for fresh history after returning', (
      tester,
    ) async {
      final assessmentCompleted = Completer<void>();
      final initialProgress = Completer<ExamProgressResponse>();
      final refreshedProgress = Completer<ExamProgressResponse>();
      final examService = _IntroHistoryExamService(
        stats: const <ExamStats>[
          ExamStats(
            correctNumber: 5,
            scorePercentage: 100,
            skippedNumber: 0,
            totalQuestions: 5,
            grade: 2,
          ),
        ],
        progress: ExamProgressResponse(
          mstatus: 200,
          series: <ExamProgressPoint>[
            ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, 1),
              correctNumber: 5,
              examId: 1,
              score: 10,
              scorePct: 100,
              sequence: 1,
              totalQuestions: 5,
              grade: 2,
              status: 'COMPLETE',
            ),
          ],
        ),
        onGetProgress: (call) =>
            call == 1 ? initialProgress.future : refreshedProgress.future,
      );
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<GuestAccountService>.value(
              value: _FakeGuestAccountService(),
            ),
            RepositoryProvider<ExamService>.value(value: examService),
          ],
          child: LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: ThemeData(extensions: const [AppThemeColors.light]),
              home: WelcomeAssessmentIntroScreen(
                onAssessment: (_) => assessmentCompleted.future,
                onSkip: () {},
              ),
            ),
          ),
        ),
      );
      expect(
        find.byKey(const ValueKey('welcome-assessment-intro-history-skeleton')),
        findsOneWidget,
      );
      expect(find.byType(AssessmentProgressionChart), findsNothing);
      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsNothing,
      );
      initialProgress.complete(
        ExamProgressResponse(
          mstatus: 200,
          series: <ExamProgressPoint>[
            ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, 1),
              correctNumber: 5,
              examId: 1,
              score: 10,
              scorePct: 100,
              sequence: 1,
              totalQuestions: 5,
              grade: 2,
              status: 'COMPLETE',
            ),
          ],
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final fade = tester.widget<Opacity>(
        find.byKey(const ValueKey('welcome-assessment-intro-history-content')),
      );
      expect(fade.opacity, greaterThan(0));
      expect(fade.opacity, lessThan(1));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AssessmentProgressionChart>(
              find.byType(AssessmentProgressionChart),
            )
            .finalGrade,
        2,
      );

      await tester.tap(
        find.byKey(const ValueKey('welcome-assessment-intro-action')),
      );
      await tester.pump();
      assessmentCompleted.complete();
      await tester.pump();

      expect(examService.statsCalls, 0);
      expect(examService.progressCalls, 2);
      expect(
        find.byKey(const ValueKey('welcome-assessment-intro-history-skeleton')),
        findsOneWidget,
      );
      expect(find.byType(AssessmentProgressionChart), findsNothing);
      expect(
        find.byKey(const ValueKey('placement-grade-ribbon')),
        findsNothing,
      );

      refreshedProgress.complete(
        ExamProgressResponse(
          mstatus: 200,
          series: <ExamProgressPoint>[
            ExamProgressPoint(
              completedDt: DateTime.utc(2026, 1, 2),
              correctNumber: 5,
              examId: 2,
              score: 10,
              scorePct: 100,
              sequence: 2,
              totalQuestions: 5,
              grade: 4,
              status: 'COMPLETE',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('welcome-assessment-intro-history-skeleton')),
        findsNothing,
      );
      final chart = tester.widget<AssessmentProgressionChart>(
        find.byType(AssessmentProgressionChart),
      );
      expect(chart.finalGrade, 4);
      expect(chart.testNumbers, <int>[2]);
    });

    testWidgets('assessment intro uses the English title in English mode', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      final lingo = LingoProvider();
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        NumiApp(
          lingoProvider: lingo,
          services: AppServices(
            guestAccountService: _FakeGuestAccountService(),
            examService: _IntroHistoryExamService(
              stats: const <ExamStats>[],
              progress: const ExamProgressResponse(mstatus: 200),
            ),
          ),
        ),
      );

      await tester.ensureVisible(find.text('TEST YOUR SKILL'));
      await tester.tap(find.text('TEST YOUR SKILL'));
      await tester.pumpAndSettle();

      expect(find.text('AI MATH'), findsOneWidget);
      expect(find.text('ASESSMENT TEST'), findsOneWidget);
      expect(find.text('TOÁN AI'), findsNothing);
    });

    testWidgets(
      'continues from welcome directly to the login screen in signup mode',
      (tester) async {
        await tester.pumpWidget(const NumiApp());

        final signupButton = find.text('SIGN UP');
        await tester.ensureVisible(signupButton);
        await tester.tap(signupButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login')), findsOneWidget);
        expect(find.byKey(const ValueKey('welcome-details')), findsNothing);

        await tester.tap(find.byType(AppBackButton));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
      },
    );

    testWidgets(
      'signup entry uses email field, delays email errors until submit, and proceeds to signup screen on valid email',
      (tester) async {
        final authService = _SignupLookupAuthService();
        FlutterSecureStorage.setMockInitialValues(<String, String>{});
        await tester.pumpWidget(NumiApp(authService: authService));

        final signupButton = find.text('SIGN UP');
        await tester.ensureVisible(signupButton);
        await tester.tap(signupButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login')), findsOneWidget);
        expect(find.text('🇻🇳'), findsNothing);
        expect(
          tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
          contains('@'),
        );

        final input = find.byType(EditableText);
        await tester.enterText(input, 'invalid-email');
        await tester.pump();

        expect(authService.lookedUpNames, isEmpty);
        expect(find.text('🇻🇳'), findsNothing);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);

        final actionButton = find.byType(ElevatedButton);
        expect(
          tester.widget<ElevatedButton>(actionButton).onPressed,
          isNotNull,
        );

        await tester.tap(actionButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);
        final invalidEmailError = find.byKey(
          const ValueKey('login-name-error'),
        );
        expect(
          tester.widget<Text>(invalidEmailError).style?.color,
          tester.element(invalidEmailError).themeColors.error,
        );
        expect(find.byKey(const ValueKey('signup')), findsNothing);
        expect(authService.lookedUpNames, isEmpty);

        await tester.enterText(input, 'learner@example.com');
        await tester.pumpAndSettle();
        expect(authService.lookedUpNames, isEmpty);

        await tester.tap(actionButton);
        await tester.pumpAndSettle();

        expect(authService.lookedUpNames, <String>['learner@example.com']);
        expect(find.byKey(const ValueKey('signup')), findsOneWidget);
        expect(find.text('learner@example.com'), findsOneWidget);
        final signupEmailField = tester
            .widgetList<TextField>(find.byType(TextField))
            .singleWhere(
              (field) => field.controller?.text == 'learner@example.com',
            );
        expect(signupEmailField.readOnly, isTrue);
      },
    );

    testWidgets('signup shows an inline error for an existing email', (
      tester,
    ) async {
      final authService = _SignupLookupAuthService(accountExists: true);
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(NumiApp(authService: authService));

      final signupButton = find.text('SIGN UP');
      await tester.ensureVisible(signupButton);
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'learner@example.com');
      await tester.pumpAndSettle();
      expect(authService.lookedUpNames, isEmpty);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(authService.lookedUpNames, <String>['learner@example.com']);
      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(find.byKey(const ValueKey('signup')), findsNothing);
      expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);
      final errorText = tester.widget<Text>(
        find.byKey(const ValueKey('login-name-error')),
      );
      expect(errorText.data?.toLowerCase(), contains('email'));
    });

    testWidgets('returns login to the welcome screen that opened it', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(const NumiApp());

      final welcomeLogin = find.text('ĐĂNG NHẬP');
      await tester.ensureVisible(welcomeLogin);
      await tester.tap(welcomeLogin);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);

      await tester.tap(find.byType(AppBackButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('welcome')), findsOneWidget);
    });

    testWidgets(
      'reveals the phone region for digits and delays email errors until submit',
      (tester) async {
        FlutterSecureStorage.setMockInitialValues(<String, String>{});
        await tester.pumpWidget(const NumiApp());

        final welcomeLogin = find.text('ĐĂNG NHẬP');
        await tester.ensureVisible(welcomeLogin);
        await tester.tap(welcomeLogin);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login')), findsOneWidget);
        expect(find.text('🇻🇳'), findsNothing);

        final input = find.byType(EditableText);
        await tester.enterText(input, 'learner');
        await tester.pump();

        expect(find.text('🇻🇳'), findsNothing);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);

        final submitButton = find.byType(ElevatedButton);
        expect(
          tester.widget<ElevatedButton>(submitButton).onPressed,
          isNotNull,
        );

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);

        await tester.enterText(input, '090');
        await tester.pumpAndSettle();

        expect(find.text('🇻🇳'), findsOneWidget);
        expect(find.byKey(const ValueKey('login-name-error')), findsNothing);
      },
    );

    testWidgets('shows login failures below the input instead of a dialog', (
      tester,
    ) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(
        NumiApp(authService: _FailingLoginLookupAuthService()),
      );

      final welcomeLogin = find.text('ĐĂNG NHẬP');
      await tester.ensureVisible(welcomeLogin);
      await tester.tap(welcomeLogin);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'learner@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Service unavailable'), findsOneWidget);
      expect(find.byKey(const ValueKey('login-name-error')), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('clears the login input after logout', (tester) async {
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      await tester.pumpWidget(NumiApp(authService: _FakeAuthService()));

      final welcomeLogin = find.text('ĐĂNG NHẬP');
      await tester.ensureVisible(welcomeLogin);
      await tester.tap(welcomeLogin);
      await tester.pumpAndSettle();

      final input = find.byType(EditableText);
      await tester.enterText(input, 'learner@example.com');
      await tester.pump();

      final sessionCubit = tester
          .element(find.byKey(const ValueKey('login')))
          .read<AppSessionCubit>();
      sessionCubit.authenticate(
        const AuthenticatedSession(user: LoginUser(id: 7, role: 'STUDENT')),
      );
      await tester.pumpAndSettle();

      expect(sessionCubit.state.status, SessionStatus.authenticated);

      await sessionCubit.logout();
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login')), findsOneWidget);
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        isEmpty,
      );
    });
  });
}
