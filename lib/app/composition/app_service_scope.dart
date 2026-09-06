import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/composition/app_services.dart';
import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/dashboard/navigation/dashboard_navigator.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/quiz/data/quiz_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/data/quiz_snapshot_store.dart';
import 'package:numi/features/session/data/passcode_service.dart';
import 'package:numi/features/session/data/profile_session_resolver.dart';

/// Exposes application-scoped service interfaces above the Navigator.
class AppServiceScope extends StatelessWidget {
  const AppServiceScope({
    super.key,
    required this.services,
    required this.child,
  });

  final AppServices services;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>.value(value: services.authService),
        RepositoryProvider<ProfileService>.value(
          value: services.profileService,
        ),
        RepositoryProvider<GradeService>.value(value: services.gradeService),
        RepositoryProvider<SchoolService>.value(value: services.schoolService),
        RepositoryProvider<ClassroomService>.value(
          value: services.classroomService,
        ),
        RepositoryProvider<ClassroomExerciseService>.value(
          value: services.classroomExerciseService,
        ),
        RepositoryProvider<QuizService>.value(value: services.quizService),
        RepositoryProvider<NotificationListService>.value(
          value: services.notificationService,
        ),
        RepositoryProvider<NotificationPingService>.value(
          value: services.notificationPingService,
        ),
        RepositoryProvider<HomeLayoutService>.value(
          value: services.homeLayoutService,
        ),
        RepositoryProvider<QuizShakeService>.value(
          value: services.quizShakeService,
        ),
        RepositoryProvider<QuizSnapshotStore>.value(
          value: services.quizSnapshotStore,
        ),
        RepositoryProvider<SessionDataCleaner>.value(
          value: services.sessionDataCleaner,
        ),
        RepositoryProvider<DashboardTabFactory>.value(
          value: services.dashboardTabFactory,
        ),
        RepositoryProvider<DashboardNavigator>.value(
          value: services.dashboardNavigator,
        ),
        RepositoryProvider<ActiveProfileSession>.value(
          value: services.activeProfileSession,
        ),
        RepositoryProvider<PasscodeService>.value(
          value: services.passcodeService,
        ),
        RepositoryProvider<ProfileSessionResolver>.value(
          value: services.profileSessionResolver,
        ),
      ],
      child: child,
    );
  }
}
