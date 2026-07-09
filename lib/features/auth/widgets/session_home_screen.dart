import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/auth/auth_cubit.dart';
import 'package:numi/features/classroom/classroom_api.dart';
import 'package:numi/features/home/home_screen.dart';
import 'package:numi/features/homework/homework_api.dart';
import 'package:numi/features/profile/grade_api.dart';
import 'package:numi/features/session/presentation/bloc/app_session_cubit.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';

class SessionHomeScreen extends StatelessWidget {
  const SessionHomeScreen({super.key});

  static bool _shouldRebuildHome(
    AppSessionState previous,
    AppSessionState current,
  ) {
    return previous.user != current.user ||
        previous.profiles != current.profiles ||
        previous.activeProfile != current.activeProfile ||
        previous.profileLoadError != current.profileLoadError;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSessionCubit, AppSessionState>(
      buildWhen: _shouldRebuildHome,
      builder: (context, session) {
        final onboarding = context.read<AuthCubit>();
        return HomeScreen(
          user: session.user,
          profiles: session.profiles,
          activeProfile: session.activeProfile,
          activeRole: session.activeRole,
          profileLoadError: session.profileLoadError,
          onRefreshProfiles: onboarding.refreshProfiles,
          onActivateProfile: onboarding.activateProfile,
          onBack: onboarding.openLogin,
          onLogout: onboarding.logout,
          gradeService: context.read<GradeService>(),
          classroomService: context.read<ClassroomService>(),
          assignmentService: context.read<ClassroomExerciseService>(),
        );
      },
    );
  }
}
