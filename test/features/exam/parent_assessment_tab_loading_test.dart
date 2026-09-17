import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/data/exam_shake_service.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/grade_selection_screen.dart';
import 'package:numi/features/exam/screens/grade_roadmap_screen.dart';
import 'package:numi/features/exam/screens/parent_assessment_tab.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_active_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_full_skeleton.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_card.dart';
import 'package:numi/features/exam/widgets/parent_assessment/parent_assessment_tab_banner.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';

void main() {
  testWidgets('second banner opens GRADE roadmap directly', (tester) async {
    final lingo = LingoProvider();
    final examService = _CountingExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      RepositoryProvider<ExamShakeService>.value(
        value: const _TestExamShakeService(),
        child: LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: ParentAssessmentTab(
              user: const LoginUser(id: 981243),
              activeProfile: const StudentProfile(
                profileId: 981243,
                role: 'STUDENT',
              ),
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const <GradeModel>[
                GradeModel(id: 3, label: 'Lớp 3', displayOrder: 3),
              ],
              gradeService: _FakeGradeService(),
              examService: examService,
              bottomPadding: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final secondBanner = find.image(
      const AssetImage(parentHomeAfterReviewBannerAsset),
    );
    await tester.ensureVisible(secondBanner);
    await tester.pump();
    await tester.tap(secondBanner);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(examService.statsCalls, 1);
    expect(examService.requestedExamTypes, const <String>[examTypeGrade]);
    expect(find.byType(ParentAssessmentTabBanner), findsNothing);
    expect(find.byType(GradeSelectionScreen), findsNothing);
    expect(find.byType(GradeRoadmapScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('grade-roadmap-level-1')), findsOneWidget);
  });

  testWidgets('active assessment resumes from stats without loading detail', (
    tester,
  ) async {
    final lingo = LingoProvider();
    final examService = _ActiveAssessmentExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      LingoScope(
        lingo: lingo,
        child: MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: ParentAssessmentTab(
            user: const LoginUser(id: 981245),
            activeProfile: const StudentProfile(
              profileId: 981245,
              role: 'STUDENT',
            ),
            isActive: true,
            activeRefreshTick: 0,
            initialGrades: const <GradeModel>[],
            gradeService: _FakeGradeService(),
            examService: examService,
            bottomPadding: 0,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(
      find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ParentAssessmentTabBanner), findsOneWidget);
    expect(find.byType(ParentAssessmentActiveCard), findsOneWidget);
    expect(find.byType(AiAssessmentScreen), findsNothing);

    await tester.tap(find.byType(ParentAssessmentTabBanner));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('active-assessment-dialog')),
      findsNothing,
    );
    expect(examService.requestedDetailId, isNull);
    expect(examService.requestedUserExamId, isNull);
    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(find.text('Resume question 3'), findsOneWidget);
    final assessment = tester.widget<AiAssessmentScreen>(
      find.byType(AiAssessmentScreen),
    );
    expect(assessment.allowQuestionNavigation, isFalse);
    expect(assessment.showQuestionNavigation, isFalse);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('assessment-leave-active')));
    await tester.pumpAndSettle();

    expect(examService.submittedAnswers, isNull);
    expect(examService.updatedUserExamId, isNull);
    expect(examService.updatedStatus, isNull);
    expect(find.byType(AiAssessmentScreen), findsNothing);
    expect(find.byType(ParentAssessmentActiveCard), findsOneWidget);
    expect(find.byType(ParentAssessmentFullSkeleton), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('parent-assessment-active-continue')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('active-assessment-dialog')),
      findsNothing,
    );
    expect(find.byType(AiAssessmentScreen), findsOneWidget);
  });

  testWidgets(
    'completed journey does not show continue when an inner exam is still active',
    (tester) async {
      final lingo = LingoProvider();
      final examService = _ActiveAssessmentExamService(outerStatus: 'COMPLETE');
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: ParentAssessmentTab(
              user: const LoginUser(id: 981245),
              activeProfile: const StudentProfile(
                profileId: 981245,
                role: 'STUDENT',
              ),
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const <GradeModel>[],
              gradeService: _FakeGradeService(),
              examService: examService,
              bottomPadding: 0,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ParentAssessmentActiveCard), findsNothing);
      expect(find.byType(AssessmentResultListItemCard), findsOneWidget);
      expect(find.byType(AiAssessmentScreen), findsNothing);
    },
  );

  testWidgets(
    'canceling an active assessment updates status and removes card',
    (tester) async {
      final lingo = LingoProvider();
      final examService = _ActiveAssessmentExamService();
      addTearDown(lingo.dispose);

      await tester.pumpWidget(
        LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
            ),
            home: ParentAssessmentTab(
              user: const LoginUser(id: 981245),
              activeProfile: const StudentProfile(
                profileId: 981245,
                role: 'STUDENT',
              ),
              isActive: true,
              activeRefreshTick: 0,
              initialGrades: const <GradeModel>[],
              gradeService: _FakeGradeService(),
              examService: examService,
              bottomPadding: 0,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(
        find.image(const AssetImage(homeInitialAssessmentBannerAsset)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ParentAssessmentTabBanner), findsOneWidget);
      expect(find.byType(AiAssessmentScreen), findsNothing);

      await tester.tap(find.byType(ParentAssessmentTabBanner));
      await tester.pumpAndSettle();
      expect(find.byType(AiAssessmentScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('assessment-cancel-attempt')));
      await tester.pumpAndSettle();

      expect(examService.updatedUserExamId, 8100);
      expect(examService.updatedStatus, 'CANCEL');
      expect(find.byType(ParentAssessmentActiveCard), findsNothing);
    },
  );
}

class _CountingExamService implements ExamService {
  int statsCalls = 0;
  final List<String> requestedExamTypes = <String>[];

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async => _testExam;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    statsCalls++;
    requestedExamTypes.add(examType);
    return const <ExamStats>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveAssessmentExamService extends _CountingExamService {
  _ActiveAssessmentExamService({this.outerStatus = 'ACTIVE'});

  final String outerStatus;
  bool _isCanceled = false;
  int? requestedDetailId;
  int? requestedUserExamId;
  int? updatedUserExamId;
  String? updatedStatus;
  List<SubmitExamAnswer>? submittedAnswers;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    statsCalls++;
    requestedExamTypes.add(examType);
    if (_isCanceled) {
      return const <ExamStats>[];
    }
    return <ExamStats>[
      ExamStats(
        correctNumber: 2,
        scorePercentage: 40,
        skippedNumber: 3,
        totalQuestions: 5,
        examType: examTypeAssessment,
        userExamId: 8100,
        status: outerStatus,
        grade: 1,
        level: 1,
        lastSubmittedDt: DateTime.utc(2026, 9, 13, 8, 30),
        inProgressExams: const <GeneratedExam>[_activeResumeExam],
      ),
    ];
  }

  @override
  Future<GeneratedExam> getExamDetail(
    int detailId, {
    int? profileId,
    int? userExamId,
    String examType = examTypeAssessment,
  }) async {
    requestedDetailId = detailId;
    requestedUserExamId = userExamId;
    throw StateError('Resume must use in_progress_exam from /exams/stats.');
  }

  @override
  Future<GeneratedExam> submitExam({
    required int examId,
    required List<SubmitExamAnswer> answers,
    int? profileId,
  }) async {
    submittedAnswers = List<SubmitExamAnswer>.from(answers);
    return GeneratedExam(
      examId: examId,
      userAiExamId: examId,
      userExamId: 8100,
      profileId: profileId,
      examStatus: 'SUBMITTED',
      examType: examTypeAssessment,
      questions: const <ExamQuestion>[],
    );
  }

  @override
  Future<void> updateUserExamStatus({
    required int userExamId,
    required String status,
    int? profileId,
  }) async {
    updatedUserExamId = userExamId;
    updatedStatus = status;
    _isCanceled = status == 'CANCEL';
  }
}

class _FakeGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async =>
      const <GradeModel>[];
}

class _TestExamShakeService implements ExamShakeService {
  const _TestExamShakeService();

  @override
  Future<void> aiShake() async {}
}

const _testExam = GeneratedExam(
  examId: 7001,
  questions: <ExamQuestion>[
    ExamQuestion(
      questionName: '12 + 8 = ?',
      questionNumber: 1,
      rightAnswer: 'C',
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '18'),
        ExamAnswer(label: 'B', content: '19'),
        ExamAnswer(label: 'C', content: '20'),
        ExamAnswer(label: 'D', content: '21'),
      ],
    ),
  ],
);

const _activeResumeExam = GeneratedExam(
  examId: 8200,
  userAiExamId: 8200,
  userExamId: 8100,
  examStatus: 'IN_PROGRESS',
  examType: examTypeAssessment,
  grade: 1,
  answers: <SubmitExamAnswer>[
    SubmitExamAnswer(questionNumber: 1, label: 'A'),
    SubmitExamAnswer(questionNumber: 2, label: 'B'),
  ],
  questions: <ExamQuestion>[
    ExamQuestion(
      questionName: 'Resume question 1',
      questionNumber: 1,
      rightAnswer: 'A',
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '1'),
        ExamAnswer(label: 'B', content: '2'),
      ],
    ),
    ExamQuestion(
      questionName: 'Resume question 2',
      questionNumber: 2,
      rightAnswer: 'A',
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '2'),
        ExamAnswer(label: 'B', content: '3'),
      ],
    ),
    ExamQuestion(
      questionName: 'Resume question 3',
      questionNumber: 3,
      rightAnswer: 'A',
      answers: <ExamAnswer>[
        ExamAnswer(label: 'A', content: '3'),
        ExamAnswer(label: 'B', content: '4'),
      ],
    ),
  ],
);
