import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/home/data/cache/home_profile_cache.dart';
import 'package:numi/features/home/application/contracts/home_layout_service.dart';
import 'package:numi/features/home/domain/models/home_layout.dart';
import 'package:numi/features/home/parent/home/parent_home_tab.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/quiz/domain/models/quiz.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';

void main() {
  testWidgets('parent home refreshes assessments in the background on entry', (
    tester,
  ) async {
    const profileId = 81521;
    final cache = HomeProfileCache.instance;
    cache.invalidateProfile(profileId);
    addTearDown(() => cache.invalidateProfile(profileId));

    final lingo = LingoProvider();
    final quizService = _RecordingQuizService();
    const homeService = _EmptyParentHomeService();
    addTearDown(lingo.dispose);

    Future<void> pumpParentHome({required bool isActive}) {
      return tester.pumpWidget(
        RepositoryProvider<HomeLayoutService>.value(
          value: homeService,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: LingoScope(
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
                quizService: quizService,
                onRefreshProfiles: _doNothing,
                onActivateProfile: _activateNothing,
                onProfileSaved: _doNothingSync,
                onOpenProfileMenu: _doNothingSync,
                onOpenClassroomTab: _doNothingSync,
                onOpenPracticeTab: _doNothingSync,
                onParentAssessmentStateChanged: (_) {},
                bottomPadding: 0,
              ),
            ),
          ),
        ),
      );
    }

    await pumpParentHome(isActive: true);
    await tester.pump();
    expect(quizService.profileRequests, const <int?>[profileId]);

    await pumpParentHome(isActive: false);
    await pumpParentHome(isActive: true);
    await tester.pump();
    expect(quizService.profileRequests, const <int?>[profileId, profileId]);
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

class _RecordingQuizService implements QuizService {
  final List<int?> profileRequests = <int?>[];

  @override
  Future<QuizListResponse> listQuizPage({
    int? userId,
    int? profileId,
    required int page,
    required int size,
    bool takeAll = false,
  }) async {
    profileRequests.add(profileId);
    return const QuizListResponse(
      mstatus: 200,
      quizzes: <GeneratedQuiz>[
        GeneratedQuiz(
          quizId: 991,
          purpose: quizPurposeAssessment,
          quizStatus: 'SUBMITTED',
          questions: <QuizQuestion>[],
        ),
      ],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyGradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async {
    return const <GradeModel>[];
  }
}
