import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/composition/app_services.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/home/data/home_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/notifications/data/notification_api.dart';
import 'package:numi/features/notifications/data/notification_ping_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/features/quiz/data/ai_shake_service.dart';
import 'package:numi/features/quiz/data/quiz_api.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

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
