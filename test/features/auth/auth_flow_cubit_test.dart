import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/auth_flow_cubit.dart';
import 'package:numi/features/auth/auth_flow_state.dart';

void main() {
  test(
    'preserves the welcome-to-signup entry flow without a session',
    () async {
      final cubit = AuthFlowCubit(
        onAuthenticated: (_) {},
        onSessionCleared: () {},
        onSessionRestoreStarted: () {},
      );

      cubit.openWelcomeDetails();
      expect(cubit.state.screen, AppScreen.welcomeDetails);

      cubit.openSignupEntry();
      expect(cubit.state.screen, AppScreen.login);
      expect(cubit.state.authEntryMode, AuthEntryMode.signup);
      await cubit.close();
    },
  );
}
