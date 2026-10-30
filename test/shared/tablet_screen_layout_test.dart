import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/screens/device_verification_screen.dart';
import 'package:numi/features/auth/screens/login_screen.dart';
import 'package:numi/features/auth/screens/otp_screen.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';
import 'package:numi/features/auth/screens/registration_profile_screen.dart';
import 'package:numi/features/auth/screens/signup_screen.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_view.dart';
import 'package:numi/features/auth/widgets/auth_header.dart';
import 'package:numi/features/games/screens/games_coming_soon_tab.dart';
import 'package:numi/features/welcome/screens/welcome_details_screen.dart';
import 'package:numi/features/welcome/widgets/welcome_details_feature_grid.dart';
import 'package:numi/shared/widgets/loading_screen.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  for (final size in const [Size(1032, 1376), Size(1376, 1032)]) {
    for (final screen in [
      'login',
      'signup',
      'otp',
      'passcode',
      'registration profile',
      'device verification',
      'welcome details',
      'games',
      'loading',
    ]) {
      testWidgets('$screen fills tablet width and centers content at $size', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        final lingo = LingoProvider();
        final controller = TextEditingController();
        addTearDown(lingo.dispose);
        addTearDown(controller.dispose);
        final bindings = AuthEntryBindings(
          controller: controller,
          region: PhoneRegion.vn,
          showPhoneRegion: true,
          onRegionChanged: (_) {},
          onBack: () {},
          onSubmitIdentifier: () {},
          isSubmitting: false,
          isCheckingIdentifier: false,
          canSubmit: true,
          canLoginWithPin: true,
          onLoginWithPin: () {},
          onSwitchEntryMode: () {},
          onIdentifierChanged: (_) {},
        );
        final (page, content) = switch (screen) {
          'login' => (LoginScreen(bindings: bindings), find.byType(AuthHeader)),
          'signup' => (
            SignupScreen(bindings: bindings),
            find.byType(AuthHeader),
          ),
          'otp' => (
            OtpScreen(
              onBack: () {},
              onConfirm: (_) {},
              onResend: () {},
              isVerifyingOtp: false,
              resendSeconds: 0,
              resendResetId: 0,
              showResendCountdown: false,
            ),
            find.byType(AuthHeader),
          ),
          'passcode' => (
            PasscodeScreen(
              mode: PasscodeScreenMode.unlock,
              onBack: () {},
              onSubmit: (_) async => null,
            ),
            find.byType(AuthHeader),
          ),
          'registration profile' => (
            RegistrationProfileScreen(
              onBack: () {},
              onContinue: (_) {},
              isSigningUp: false,
            ),
            find.byType(TextField),
          ),
          'device verification' => (
            DeviceVerificationScreen(
              devices: const [],
              selectedDeviceId: null,
              isLoading: false,
              isSending: false,
              onBack: () {},
              onRetry: () {},
              onSelectDevice: (_) {},
              onSend: () {},
            ),
            find.byType(AuthHeader),
          ),
          'welcome details' => (
            WelcomeDetailsScreen(onSignup: () {}, onBack: () {}),
            find.byType(WelcomeDetailsFeatureGrid),
          ),
          'games' => (
            const GamesComingSoonTab(bottomPadding: 80),
            find.byType(Image),
          ),
          _ => (const LoadingScreen(), find.byType(Image)),
        };

        await tester.pumpWidget(
          LingoScope(
            lingo: lingo,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: Scaffold(body: SafeArea(child: page)),
            ),
          ),
        );
        // Loading and focused input fields animate continuously.
        await tester.pump(const Duration(milliseconds: 500));

        final pageRect = tester.getRect(find.byWidget(page));
        expect(pageRect.left, 0);
        expect(pageRect.width, size.width);
        expect(content, findsOneWidget);
        expect(tester.getCenter(content).dx, closeTo(size.width / 2, 0.1));
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
