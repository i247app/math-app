import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/screens/parent/parent_home_tab.dart';
import 'package:numi/features/home/widgets/sections/banner/banner.dart';
import 'package:numi/features/home/widgets/sections/assessment_list/home_assessment_result_card.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/screens/assessment_screen.dart';
import 'package:numi/features/exam/screens/open_initial_assessment_from_home.dart';

void main() {
  testWidgets('home banner resumes the active assessment after leaving', (
    tester,
  ) async {
    const profileId = 81522;
    final cache = HomeProfileCache.instance;
    cache.invalidateProfile(profileId);
    addTearDown(() => cache.invalidateProfile(profileId));

    final lingo = LingoProvider();
    final examService = _ActiveHomeExamService();
    addTearDown(lingo.dispose);

    await tester.pumpWidget(
      RepositoryProvider<HomeLayoutService>.value(
        value: const _EmptyParentHomeService(),
        child: LingoScope(
          lingo: lingo,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: ParentHomeContent(
                user: const LoginUser(id: 271),
                profiles: const <StudentProfile>[],
                activeProfile: const StudentProfile(
                  profileId: profileId,
                  role: 'PARENT',
                ),
                isActive: true,
                activeRefreshTick: 0,
                initialGrades: const <GradeModel>[],
                gradeService: _EmptyGradeService(),
                examService: examService,
                onRefreshProfiles: _doNothing,
                onActivateProfile: _activateNothing,
                onProfileSaved: _doNothingSync,
                onOpenProfileMenu: _doNothingSync,
                onOpenClassroomTab: _doNothingSync,
                onOpenPracticeTab: _doNothingSync,
                onParentAssessmentStateChanged: (_) {},
                bottomPadding: 0,
                onOpenInitialAssessment: (context) =>
                    openInitialAssessmentFromHome(
                      context: context,
                      examService: examService,
                      profileId: profileId,
                      gradeLabel: null,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final statsCallsBeforeFirstTap = examService.statsCalls;
    await tester.tap(find.byType(HomeBanner).first);
    await tester.pumpAndSettle();
    expect(find.byType(AiAssessmentScreen), findsOneWidget);
    expect(find.text('Resume question 3'), findsOneWidget);
    expect(examService.generatedCount, 0);
    expect(examService.statsCalls, statsCallsBeforeFirstTap + 1);

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('assessment-leave-active')));
    await tester.pumpAndSettle();

    final statsCallsBeforeSecondTap = examService.statsCalls;
    await tester.tap(find.byType(HomeBanner).first);
    await tester.pumpAndSettle();
    expect(find.text('Resume question 3'), findsOneWidget);
    expect(examService.generatedCount, 0);
    expect(examService.statsCalls, statsCallsBeforeSecondTap + 1);
  });

  testWidgets('initial assessment banner opens the direct assessment action', (
    tester,
  ) async {
    const profileId = 81520;
    final cache = HomeProfileCache.instance;
    cache.invalidateProfile(profileId);
    addTearDown(() => cache.invalidateProfile(profileId));

    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    var directAssessmentOpenCount = 0;
    var gradeSelectionOpenCount = 0;

    await tester.pumpWidget(
      RepositoryProvider<HomeLayoutService>.value(
        value: const _EmptyParentHomeService(),
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: LingoScope(
              lingo: lingo,
              child: ParentHomeContent(
                user: const LoginUser(id: 271),
                profiles: const <StudentProfile>[],
                activeProfile: const StudentProfile(
                  profileId: profileId,
                  role: 'PARENT',
                ),
                isActive: true,
                activeRefreshTick: 0,
                initialGrades: const <GradeModel>[],
                gradeService: _EmptyGradeService(),
                examService: _EmptyExamService(),
                onRefreshProfiles: _doNothing,
                onActivateProfile: _activateNothing,
                onProfileSaved: _doNothingSync,
                onOpenProfileMenu: _doNothingSync,
                onOpenClassroomTab: _doNothingSync,
                onOpenPracticeTab: _doNothingSync,
                onParentAssessmentStateChanged: (_) {},
                bottomPadding: 0,
                onOpenAssessment: (_) async => gradeSelectionOpenCount++,
                onOpenInitialAssessment: (_) async =>
                    directAssessmentOpenCount++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(HomeBanner).first);
    await tester.pumpAndSettle();

    expect(directAssessmentOpenCount, 1);
    expect(gradeSelectionOpenCount, 0);
  });

  testWidgets('parent home refreshes assessments in the background on entry', (
    tester,
  ) async {
    const profileId = 81521;
    final cache = HomeProfileCache.instance;
    cache.invalidateProfile(profileId);
    addTearDown(() => cache.invalidateProfile(profileId));

    final lingo = LingoProvider();
    final examService = _RecordingExamService();
    const homeService = _EmptyParentHomeService();
    addTearDown(lingo.dispose);
    GeneratedExam? openedResult;

    Future<void> pumpParentHome({required bool isActive}) {
      return tester.pumpWidget(
        RepositoryProvider<HomeLayoutService>.value(
          value: homeService,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: LingoScope(
                lingo: lingo,
                child: ParentHomeContent(
                  user: const LoginUser(id: 271),
                  profiles: const <StudentProfile>[],
                  activeProfile: const StudentProfile(
                    profileId: profileId,
                    role: 'PARENT',
                  ),
                  isActive: isActive,
                  activeRefreshTick: 0,
                  initialGrades: const <GradeModel>[],
                  gradeService: _EmptyGradeService(),
                  examService: examService,
                  onRefreshProfiles: _doNothing,
                  onActivateProfile: _activateNothing,
                  onProfileSaved: _doNothingSync,
                  onOpenProfileMenu: _doNothingSync,
                  onOpenClassroomTab: _doNothingSync,
                  onOpenPracticeTab: _doNothingSync,
                  onParentAssessmentStateChanged: (_) {},
                  bottomPadding: 0,
                  onOpenExamReview: (_, exam) async {
                    openedResult = exam;
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    await pumpParentHome(isActive: true);
    await tester.pump();
    expect(examService.profileRequests, const <int?>[profileId]);
    expect(examService.requestedExamTypes, const <String>[examTypeAssessment]);
    expect(examService.listCalls, 0);
    expect(examService.listPageCalls, 0);

    await pumpParentHome(isActive: false);
    await pumpParentHome(isActive: true);
    await tester.pump();
    expect(examService.profileRequests, const <int?>[profileId, profileId]);
    expect(examService.listCalls, 0);
    expect(examService.listPageCalls, 0);

    await tester.pumpAndSettle();
    expect(find.byType(HomeAssessmentResultCard), findsOneWidget);
    await tester.ensureVisible(find.byType(HomeAssessmentResultCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(HomeAssessmentResultCard));
    await tester.pump();
    expect(openedResult?.userExamId, 991);
    expect(openedResult?.grading?.scorePercentage, 80);
  });
}

Future<void> _doNothing() async {}

Future<void> _activateNothing(StudentProfile _) async {}

void _doNothingSync() {}

class _EmptyParentHomeService implements HomeLayoutService {
  const _EmptyParentHomeService();

  @override
  Future<HomeLayout> getLayout({required int profileId}) async {
    return const HomeLayout(role: 'PARENT');
  }
}

class _RecordingExamService implements ExamService {
  final List<int?> profileRequests = <int?>[];
  final List<String> requestedExamTypes = <String>[];
  int listCalls = 0;
  int listPageCalls = 0;

  @override
  Future<List<GeneratedExam>> listExams({int? userId, int? profileId}) async {
    listCalls++;
    return const <GeneratedExam>[];
  }

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    profileRequests.add(profileId);
    requestedExamTypes.add(examType);
    return <ExamStats>[
      ExamStats(
        correctNumber: 8,
        scorePercentage: 80,
        skippedNumber: 0,
        totalQuestions: 10,
        userExamId: 991,
        examType: examTypeAssessment,
        status: 'COMPLETE',
        grade: 2,
        lastSubmittedDt: DateTime.utc(2026, 9, 22),
      ),
      const ExamStats(
        correctNumber: 0,
        scorePercentage: 0,
        skippedNumber: 0,
        totalQuestions: 3,
        status: 'ACTIVE',
        inProgressExams: <GeneratedExam>[_homeActiveExam],
      ),
      const ExamStats(
        correctNumber: 0,
        scorePercentage: 0,
        skippedNumber: 0,
        totalQuestions: 3,
        status: 'CANCEL',
      ),
    ];
  }

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    listPageCalls++;
    return const ExamListResponse(mstatus: 200);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyExamService implements ExamService {
  @override
  Future<List<GeneratedExam>> listExams({int? userId, int? profileId}) async {
    return const <GeneratedExam>[];
  }

  @override
  Future<ExamListResponse> listExamPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    return const ExamListResponse(mstatus: 200, exams: <GeneratedExam>[]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveHomeExamService extends _EmptyExamService {
  int statsCalls = 0;
  int generatedCount = 0;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    String examType = examTypeAssessment,
  }) async {
    statsCalls++;
    return const <ExamStats>[
      ExamStats(
        correctNumber: 0,
        scorePercentage: 0,
        skippedNumber: 0,
        totalQuestions: 3,
        status: 'ACTIVE',
        examType: examTypeAssessment,
        inProgressExams: <GeneratedExam>[_homeActiveExam],
      ),
    ];
  }

  @override
  Future<GeneratedExam> generateAssessmentExam({
    String examType = examTypeAssessment,
    String? gradeLabel,
    int? level,
    int? profileId,
    int? userExamId,
  }) async {
    generatedCount++;
    throw StateError('An active assessment must be resumed.');
  }
}

const _homeActiveExam = GeneratedExam(
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

class _EmptyGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async {
    return const <GradeModel>[];
  }
}
