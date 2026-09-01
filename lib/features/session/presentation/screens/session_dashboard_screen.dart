import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/session/application/controllers/app_session_cubit.dart';
import 'package:numi/features/session/application/controllers/app_session_state.dart';

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
        previous.isResolvingProfile != current.isResolvingProfile ||
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
          isResolvingProfile: session.isResolvingProfile,
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
