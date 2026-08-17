import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/dashboard/screens/dashboard_screen.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/session/application/app_session_cubit.dart';
import 'package:numi/features/session/application/app_session_state.dart';

class SessionDashboardScreen extends StatelessWidget {
  const SessionDashboardScreen({
    super.key,
    required this.onBack,
    required this.onLogout,
  });

  final VoidCallback onBack;
  final VoidCallback onLogout;

  static bool _shouldRebuildHome(
    AppSessionState previous,
    AppSessionState current,
  ) {
    return previous.user != current.user ||
        previous.profiles != current.profiles ||
        previous.activeProfile != current.activeProfile ||
        previous.profileLoadError != current.profileLoadError ||
        previous.shouldShowChildProfileDialog !=
            current.shouldShowChildProfileDialog;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSessionCubit, AppSessionState>(
      buildWhen: _shouldRebuildHome,
      builder: (context, session) {
        final sessionCubit = context.read<AppSessionCubit>();
        return DashboardScreen(
          user: session.user,
          profiles: session.profiles,
          activeProfile: session.activeProfile,
          activeRole: session.activeRole,
          profileLoadError: session.profileLoadError,
          showChildProfileDialogOnStart: session.shouldShowChildProfileDialog,
          onChildProfileDialogShown: sessionCubit.consumeChildProfileDialog,
          onRefreshProfiles: sessionCubit.refreshProfiles,
          onActivateProfile: sessionCubit.activateProfile,
          onBack: onBack,
          onLogout: onLogout,
          gradeService: context.read<GradeService>(),
          classroomService: context.read<ClassroomService>(),
          assignmentService: context.read<ClassroomExerciseService>(),
        );
      },
    );
  }
}
