import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/app/composition/app_session_data_cleaner.dart';
import 'package:numi/app/composition/app_dashboard_tab_factory.dart';
import 'package:numi/app/composition/app_dashboard_navigator.dart';
import 'package:numi/features/dashboard/application/contracts/dashboard_navigator.dart';
import 'package:numi/features/dashboard/application/contracts/dashboard_tab_factory.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/data/api/auth_api.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/data/api/classroom_api.dart';
import 'package:numi/features/home/application/contracts/home_layout_service.dart';
import 'package:numi/features/home/data/api/home_api.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/data/api/homework_api.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';
import 'package:numi/features/notifications/application/contracts/notification_ping_service.dart';
import 'package:numi/features/notifications/data/api/notification_api.dart';
import 'package:numi/features/notifications/data/api/notification_ping_service.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/features/profile/data/adapters/active_profile_session.dart';
import 'package:numi/features/profile/data/api/grade_api.dart';
import 'package:numi/features/profile/data/api/profile_api.dart';
import 'package:numi/features/profile/data/api/school_api.dart';
import 'package:numi/features/quiz/application/contracts/quiz_shake_service.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/data/adapters/ai_shake_service.dart';
import 'package:numi/features/quiz/data/api/quiz_api.dart';
import 'package:numi/features/quiz/application/contracts/quiz_snapshot_store.dart';
import 'package:numi/features/quiz/data/adapters/cached_quiz_snapshot_store.dart';
import 'package:numi/features/session/application/services/passcode_service.dart';
import 'package:numi/features/session/application/services/profile_session_resolver.dart';

/// Application composition root.
///
/// Concrete implementations are created only here. The rest of the app reads
/// the corresponding interfaces from providers or receives them explicitly.
class AppServices {
  factory AppServices({
    NetworkClient? networkClient,
    AuthService? authService,
    ProfileService? profileService,
    GradeService? gradeService,
    SchoolService? schoolService,
    ClassroomService? classroomService,
    ClassroomExerciseService? classroomExerciseService,
    QuizService? quizService,
    NotificationListService? notificationService,
    NotificationPingService? notificationPingService,
    HomeLayoutService? homeLayoutService,
    QuizShakeService? quizShakeService,
    QuizSnapshotStore quizSnapshotStore = const CachedQuizSnapshotStore(),
    SessionDataCleaner sessionDataCleaner = const AppSessionDataCleaner(),
    DashboardTabFactory? dashboardTabFactory,
    DashboardNavigator dashboardNavigator = const AppDashboardNavigator(),
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  }) {
    final client = networkClient ?? NetworkClient.shared;
    final profiles = profileService ?? ProfileApi(networkClient: client);

    final quizSnapshots = quizSnapshotStore;
    return AppServices._(
      networkClient: client,
      authService: authService ?? AuthApi(networkClient: client),
      profileService: profiles,
      gradeService: gradeService ?? GradeApi(networkClient: client),
      schoolService: schoolService ?? SchoolApi(networkClient: client),
      classroomService: classroomService ?? ClassroomApi(networkClient: client),
      classroomExerciseService:
          classroomExerciseService ??
          ClassroomExerciseApi(networkClient: client),
      quizService: quizService ?? QuizApi(networkClient: client),
      notificationService:
          notificationService ?? NotificationApi(networkClient: client),
      notificationPingService:
          notificationPingService ??
          ApiNotificationPingService(networkClient: client),
      homeLayoutService:
          homeLayoutService ?? HomeLayoutApi(networkClient: client),
      quizShakeService:
          quizShakeService ?? AIShakeService(networkClient: client),
      quizSnapshotStore: quizSnapshotStore,
      dashboardTabFactory:
          dashboardTabFactory ??
          AppDashboardTabFactory(quizSnapshotStore: quizSnapshots),
      dashboardNavigator: dashboardNavigator,
      sessionDataCleaner: sessionDataCleaner,
      activeProfileSession: activeProfileSession,
      passcodeService: passcodeService,
      profileSessionResolver: ProfileSessionResolver(
        profileService: profiles,
        activeProfileSession: activeProfileSession,
      ),
    );
  }

  const AppServices._({
    required this.networkClient,
    required this.authService,
    required this.profileService,
    required this.gradeService,
    required this.schoolService,
    required this.classroomService,
    required this.classroomExerciseService,
    required this.quizService,
    required this.notificationService,
    required this.notificationPingService,
    required this.homeLayoutService,
    required this.quizShakeService,
    required this.quizSnapshotStore,
    required this.sessionDataCleaner,
    required this.dashboardTabFactory,
    required this.dashboardNavigator,
    required this.activeProfileSession,
    required this.passcodeService,
    required this.profileSessionResolver,
  });

  final NetworkClient networkClient;
  final AuthService authService;
  final ProfileService profileService;
  final GradeService gradeService;
  final SchoolService schoolService;
  final ClassroomService classroomService;
  final ClassroomExerciseService classroomExerciseService;
  final QuizService quizService;
  final NotificationListService notificationService;
  final NotificationPingService notificationPingService;
  final HomeLayoutService homeLayoutService;
  final QuizShakeService quizShakeService;
  final QuizSnapshotStore quizSnapshotStore;
  final SessionDataCleaner sessionDataCleaner;
  final DashboardTabFactory dashboardTabFactory;
  final DashboardNavigator dashboardNavigator;
  final ActiveProfileSession activeProfileSession;
  final PasscodeService passcodeService;
  final ProfileSessionResolver profileSessionResolver;
}
