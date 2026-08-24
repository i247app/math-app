import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/application/app_coordinator_state.dart';
import 'package:numi/app/navigation/app_screen.dart';
import 'package:numi/features/auth/application/auth_state.dart';

/// Owns global flow navigation. Feature cubits publish results; this cubit
/// decides which flow is visible.
class AppCoordinatorCubit extends Cubit<AppCoordinatorState> {
  AppCoordinatorCubit({
    bool hasInitialSession = false,
    bool restoreSessionOnStart = false,
  }) : super(
         AppCoordinatorState(
           screen: hasInitialSession
               ? AppScreen.home
               : restoreSessionOnStart
               ? AppScreen.restoring
               : AppScreen.welcome,
         ),
       );

  void showWelcome() => _show(AppScreen.welcome);

  void showWelcomeDetails() => _show(AppScreen.welcomeDetails);

  void showAuthScreen(AuthScreen screen) => _show(switch (screen) {
    AuthScreen.welcome => AppScreen.welcome,
    AuthScreen.welcomeDetails => AppScreen.welcomeDetails,
    AuthScreen.login => AppScreen.login,
    AuthScreen.deviceVerification => AppScreen.deviceVerification,
    AuthScreen.otp => AppScreen.otp,
    AuthScreen.signup => AppScreen.signup,
  });

  void showLogin() => _show(AppScreen.login);

  void showPasscode() => _show(AppScreen.passcode);

  void showRestoringSession() => _show(AppScreen.restoring);

  void showHome() => _show(AppScreen.home);

  void _show(AppScreen screen) {
    if (!isClosed && state.screen != screen) {
      emit(state.copyWith(screen: screen));
    }
  }
}
