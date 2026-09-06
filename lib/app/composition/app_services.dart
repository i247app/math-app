import 'package:numi/core/network/network_client.dart';
import 'package:numi/core/data/session_data_cleaner.dart';
import 'package:numi/app/composition/app_session_data_cleaner.dart';
import 'package:numi/app/composition/app_dashboard_tab_factory.dart';
import 'package:numi/app/composition/app_dashboard_navigator.dart';
import 'package:numi/features/dashboard/navigation/dashboard_navigator.dart';
import 'package:numi/features/dashboard/navigation/dashboard_tab_factory.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/home/data/home_layout_service.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_api.dart';
import 'package:numi/features/notifications/data/notification_list_service.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/data/api_notification_ping_service.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/features/quiz/data/quiz_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_service.dart';
import 'package:numi/features/quiz/data/ai_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/quiz/data/quiz_snapshot_store.dart';
import 'package:numi/features/quiz/data/cached_quiz_snapshot_store.dart';
import 'package:numi/features/session/data/passcode_service.dart';
import 'package:numi/features/session/data/profile_session_resolver.dart';

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
