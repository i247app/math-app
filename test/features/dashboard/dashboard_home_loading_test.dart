import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/app/composition/app_dashboard_navigator.dart';
import 'package:numi/app/composition/app_dashboard_tab_factory.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_args.dart';
import 'package:numi/features/dashboard/models/dashboard_tab_id.dart';
import 'package:numi/features/dashboard/navigation/dashboard_navigator.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/screens/dashboard_screen.dart';
import 'package:numi/features/dashboard/widgets/dashboard_header_bar.dart';
import 'package:numi/features/dashboard/widgets/dashboard_session_skeleton.dart';
import 'package:numi/features/exam/data/exam_service.dart';
import 'package:numi/features/exam/models/exam.dart';
import 'package:numi/features/exam/widgets/assessment_result/assessment_progression_chart.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_profile_cache.dart';
import 'package:numi/features/home/models/home_layout.dart';
import 'package:numi/features/home/screens/parent/parent_home_tab.dart';
import 'package:numi/features/home/screens/student/student_home_tab.dart';
import 'package:numi/features/home/widgets/parent/home_content_skeleton.dart';
import 'package:numi/features/home/widgets/parent/home_skeleton.dart';
import 'package:numi/features/notifications/data/notification_cache.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/models/notification.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/profile_role.dart';

void main() {
  for (final role in [ProfileRole.parent, ProfileRole.student]) {
    testWidgets(
      '$role keeps the Home skeleton layout after profile resolution',
      (tester) async {
        const profileId = 82001;
        HomeProfileCache.instance.invalidateProfile(profileId);
        NotificationCache.invalidate();
        addTearDown(() {
          HomeProfileCache.instance.invalidateProfile(profileId);
          NotificationCache.invalidate();
        });
        final lingo = LingoProvider();
        addTearDown(lingo.dispose);
        final homeService = _DelayedHomeService();
        final examService = _DelayedExamService();
        var resolving = true;
        late StateSetter updateSession;

        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: [
              RepositoryProvider<DashboardTabFactory>.value(
                value: const _HomeTabFactory(),
              ),
              RepositoryProvider<DashboardNavigator>.value(
                value: const AppDashboardNavigator(),
              ),
              RepositoryProvider<HomeLayoutService>.value(value: homeService),
              RepositoryProvider<GradeService>.value(value: _GradeService()),
              RepositoryProvider<ClassroomService>.value(
                value: _UnusedClassroomService(),
              ),
              RepositoryProvider<ClassroomExerciseService>.value(
                value: _UnusedAssignmentService(),
              ),
              RepositoryProvider<ExamService>.value(value: examService),
              RepositoryProvider<NotificationListService>.value(
                value: _NotificationService(),
              ),
            ],
            child: LingoScope(
              lingo: lingo,
              child: MaterialApp(
                theme: AppTheme.light(),
                home: Scaffold(
                  body: StatefulBuilder(
                    builder: (context, setSessionState) {
                      updateSession = setSessionState;
                      return DashboardScreen(
                        user: LoginUser(id: 271, role: role.name.toUpperCase()),
                        profiles: const [],
                        activeProfile: resolving
                            ? null
                            : UserProfile(
                                profileId: profileId,
                                role: role.name.toUpperCase(),
                              ),
                        activeRole: role,
                        profileLoadError: null,
                        isResolvingProfile: resolving,
                        onRefreshProfiles: () async {},
                        onActivateProfile: (_) async {},
                        onBack: () {},
                        onLogout: () {},
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(HomeSkeleton), findsOneWidget);
        expect(find.byType(HomeContentSkeleton), findsOneWidget);
        expect(find.byType(DashboardSessionSkeleton), findsNothing);
        expect(find.byType(DashboardHeaderBar), findsOneWidget);
        final initialSkeletonRect = tester.getRect(
          find.byType(HomeContentSkeleton),
        );
        final initialHeaderRect = tester.getRect(
          find.byType(DashboardHeaderBar),
        );

        updateSession(() => resolving = false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.byType(HomeSkeleton), findsNothing);
        expect(find.byType(HomeContentSkeleton), findsOneWidget);
        expect(find.byType(DashboardHeaderBar), findsOneWidget);
        expect(
          tester.getRect(find.byType(HomeContentSkeleton)),
          initialSkeletonRect,
        );
        expect(
          tester.getRect(find.byType(DashboardHeaderBar)),
          initialHeaderRect,
        );
        expect(
          find.byType(
            role == ProfileRole.parent ? ParentHomeContent : StudentHomeContent,
          ),
          findsOneWidget,
        );

        homeService.layout.complete(HomeLayout(role: role.name.toUpperCase()));
        await tester.pump();
        expect(find.byType(HomeContentSkeleton), findsOneWidget);
        examService.progress.complete(
          const ExamProgressResponse(mstatus: 200, series: []),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeContentSkeleton), findsNothing);
        expect(find.byType(AssessmentProgressionChart), findsOneWidget);
        expect(find.byType(DashboardHeaderBar), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }
}

// Prewarmed tabs outside Home are unrelated to the loading transition.
class _HomeTabFactory implements DashboardTabFactory {
  const _HomeTabFactory();

  @override
  Widget buildTab({
    required BuildContext context,
    required ProfileRole role,
    required DashboardTabArgs args,
  }) => args.activeTab == DashboardTabId.home
      ? const AppDashboardTabFactory().buildTab(
          context: context,
          role: role,
          args: args,
        )
      : const SizedBox.shrink();
}

class _DelayedHomeService implements HomeLayoutService {
  final layout = Completer<HomeLayout>();

  @override
  Future<HomeLayout> getLayout({required int profileId}) => layout.future;
}

class _DelayedExamService implements ExamService {
  final progress = Completer<ExamProgressResponse>();

  @override
  Future<ExamProgressResponse> getExamProgress({
    required int profileId,
    required DateTime fromDt,
    required DateTime toDt,
    String examType = examTypeAssessment,
  }) => progress.future;

  @override
  Future<List<ExamStats>> getExamStats({
    required int profileId,
    List<String> examTypes = const [examTypeAssessment],
  }) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GradeService implements GradeService {
  @override
  Future<List<GradeModel>> listGrades({required int userId}) async => [];
}

class _NotificationService implements NotificationListService {
  @override
  Future<List<NotificationModel>> listNotifications() async => [];
}

class _UnusedClassroomService implements ClassroomService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAssignmentService implements ClassroomExerciseService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
