import 'package:numi/core/network/network_client.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/home/application/contracts/home_layout_service.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/notifications/application/contracts/notification_list_service.dart';
import 'package:numi/features/notifications/application/contracts/notification_ping_service.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/features/quiz/application/contracts/quiz_shake_service.dart';
import 'package:numi/features/quiz/application/contracts/quiz_service.dart';
import 'package:numi/features/quiz/data/ai_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

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
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  }) {
    final client = networkClient ?? NetworkClient.shared;
    final profiles = profileService ?? ProfileApi(networkClient: client);

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
  final ActiveProfileSession activeProfileSession;
  final PasscodeService passcodeService;
  final ProfileSessionResolver profileSessionResolver;
}
