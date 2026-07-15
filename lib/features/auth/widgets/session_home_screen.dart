import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/auth/application/auth_cubit.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/home/home_screen.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/grade_api.dart';
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
        final authFlow = context.read<AuthFlowCubit>();
        final sessionCubit = context.read<AppSessionCubit>();
        return HomeScreen(
          user: session.user,
          profiles: session.profiles,
          activeProfile: session.activeProfile,
          activeRole: session.activeRole,
          profileLoadError: session.profileLoadError,
          onRefreshProfiles: sessionCubit.refreshProfiles,
          onActivateProfile: sessionCubit.activateProfile,
          onBack: authFlow.openLogin,
          onLogout: authFlow.logout,
          gradeService: context.read<GradeService>(),
          classroomService: context.read<ClassroomService>(),
          assignmentService: context.read<ClassroomExerciseService>(),
        );
      },
    );
  }
}
