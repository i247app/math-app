import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/screens/login_screen.dart';
import 'package:numi/features/auth/screens/otp_screen.dart';
import 'package:numi/features/auth/screens/passcode_screen.dart';
import 'package:numi/features/auth/screens/signup_screen.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_view.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  const devices = [
    (
      size: Size(393, 852),
      top: 59.0,
      bottom: 34.0,
      keyboardHeight: 336.0,
      platform: TargetPlatform.iOS,
    ),
    (
      size: Size(375, 667),
      top: 20.0,
      bottom: 0.0,
      keyboardHeight: 336.0,
      platform: TargetPlatform.iOS,
    ),
    (
      size: Size(360, 800),
      top: 36.0,
      bottom: 24.0,
      keyboardHeight: 295.0,
      platform: TargetPlatform.android,
    ),
  ];

  for (final device in devices) {
    final keyboardHeight = device.keyboardHeight;
    Future<LingoProvider> showScreen(
      WidgetTester tester,
      Widget screen, {
      bool pushedRoute = false,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = device.size;
      tester.view.viewPadding = FakeViewPadding(
        top: device.top,
        bottom: device.bottom,
      );
      tester.view.padding = tester.view.viewPadding;
      addTearDown(tester.view.reset);
      final lingo = LingoProvider();
      addTearDown(lingo.dispose);
      final originalLanguage = AppLanguageState.current;
      addTearDown(() => AppLanguageState.current = originalLanguage);
      await lingo.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light().copyWith(platform: device.platform),
          home: LingoScope(
            lingo: lingo,
            // AppFlow leaves keyboard avoidance to the auth layout. Settings
            // also opens PIN as a route without an enclosing Scaffold.
            child: pushedRoute
                ? screen
                : Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: SafeArea(child: screen),
                  ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return lingo;
    }

    Future<void> openKeyboard(WidgetTester tester) async {
      tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
      tester.view.padding = FakeViewPadding(top: device.top);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(SingleChildScrollView)).bottom,
        lessThanOrEqualTo(device.size.height - keyboardHeight),
      );
    }

    Future<void> tapAboveKeyboard(WidgetTester tester, Finder action) async {
      await tester.ensureVisible(action);
      await tester.pumpAndSettle();
      final rect = tester.getRect(action);
      expect(rect.top, greaterThanOrEqualTo(device.top));
      expect(
        rect.bottom,
        lessThanOrEqualTo(device.size.height - keyboardHeight),
      );
      expect(tester.view.viewInsets.bottom, keyboardHeight);
      await tester.tap(action);
      await tester.pump();
      expect(tester.takeException(), isNull);
    }

    for (final mode in AuthEntryMode.values) {
      testWidgets(
        '${mode.name} actions clear keyboard on ${device.platform.name} ${device.size}',
        (tester) async {
          final controller = TextEditingController();
          final error = ValueNotifier<String?>(null);
          addTearDown(controller.dispose);
          addTearDown(error.dispose);
          var submits = 0;
          var pinTaps = 0;
          var switches = 0;
          AuthEntryBindings bindings(String? errorText) => AuthEntryBindings(
            controller: controller,
            region: PhoneRegion.vn,
            showPhoneRegion: false,
            onRegionChanged: (_) {},
            onBack: () {},
            onSubmitIdentifier: () => submits++,
            isSubmitting: false,
            isCheckingIdentifier: false,
            canSubmit: true,
            canLoginWithPin: true,
            onLoginWithPin: () => pinTaps++,
            onSwitchEntryMode: () => switches++,
            onIdentifierChanged: (_) {},
            identifierErrorText: errorText,
          );
          final lingo = await showScreen(
            tester,
            ValueListenableBuilder<String?>(
              valueListenable: error,
              builder: (context, errorText, _) => mode == AuthEntryMode.login
                  ? LoginScreen(bindings: bindings(errorText))
                  : SignupScreen(bindings: bindings(errorText)),
            ),
          );
          final scroll = find.byType(SingleChildScrollView);
          final initialViewport = tester.getRect(scroll);
          final scrollable = find
              .descendant(of: scroll, matching: find.byType(Scrollable))
              .first;
          final initialExtent = tester
              .state<ScrollableState>(scrollable)
              .position
              .maxScrollExtent;

          final switchPrompt = find.text(
            lingo.lookup(
              mode == AuthEntryMode.login
                  ? AppKeys.authSwitchToSignupPrompt
                  : AppKeys.authSwitchToLoginPrompt,
            ),
          );
          expect(
            tester.getRect(switchPrompt).bottom,
            lessThanOrEqualTo(initialViewport.bottom),
          );
          final switchAction = find.ancestor(
            of: find.text(
              lingo.lookup(
                mode == AuthEntryMode.login ? AppKeys.signup : AppKeys.login,
              ),
            ),
            matching: find.byType(InkWell),
          );
          expect(
            tester.getRect(switchAction).bottom,
            lessThanOrEqualTo(initialViewport.bottom),
          );
          await tester.tap(switchAction);
          expect(switches, 1);

          // Opening the keyboard alone must reveal the button, before typing or
          // scrolling. ensureVisible below only checks the secondary PIN action.
          await tester.tap(find.byType(TextField));
          await openKeyboard(tester);
          final actionRect = tester.getRect(find.byType(ElevatedButton));
          expect(actionRect.top, greaterThanOrEqualTo(device.top));
          expect(
            actionRect.bottom,
            lessThanOrEqualTo(device.size.height - keyboardHeight),
          );
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .focusNode
                .hasFocus,
            isTrue,
          );
          await tester.enterText(find.byType(TextField), 'review@example.com');
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byType(ElevatedButton)).bottom,
            lessThanOrEqualTo(device.size.height - keyboardHeight),
          );

          // A validation error can move the button down while the keyboard is
          // already open. Keep both the input and primary action visible.
          error.value = 'Please check the phone number or email and try again.';
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byType(TextField)).top,
            greaterThanOrEqualTo(device.top),
          );
          expect(
            tester.getRect(find.byType(ElevatedButton)).bottom,
            lessThanOrEqualTo(device.size.height - keyboardHeight),
          );
          expect(
            tester
                .widget<EditableText>(find.byType(EditableText))
                .focusNode
                .hasFocus,
            isTrue,
          );
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
          expect(submits, 1);
          if (mode == AuthEntryMode.login) {
            final pinAction = find.ancestor(
              of: find.text(lingo.lookup(AppKeys.loginWithPin)),
              matching: find.byType(InkWell),
            );
            await tapAboveKeyboard(tester, pinAction);
            expect(pinTaps, 1);
          }

          FocusManager.instance.primaryFocus?.unfocus();
          error.value = null;
          tester.view.viewInsets = FakeViewPadding.zero;
          tester.view.padding = tester.view.viewPadding;
          await tester.pumpAndSettle();
          expect(tester.getRect(scroll), initialViewport);
          expect(
            tester.state<ScrollableState>(scrollable).position.maxScrollExtent,
            initialExtent,
          );
          expect(controller.text, 'review@example.com');
          expect(
            tester.getRect(switchPrompt).bottom,
            lessThanOrEqualTo(initialViewport.bottom),
          );
          expect(
            tester.getRect(switchAction).bottom,
            lessThanOrEqualTo(initialViewport.bottom),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('OTP confirm clears keyboard on ${device.size}', (
      tester,
    ) async {
      String? submitted;
      await showScreen(
        tester,
        OtpScreen(
          onBack: () {},
          onConfirm: (code) => submitted = code,
          onResend: () {},
          isVerifyingOtp: false,
          resendSeconds: 30,
          resendResetId: 0,
          showResendCountdown: true,
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      }
      await openKeyboard(tester);
      await tapAboveKeyboard(tester, find.byType(ElevatedButton));
      expect(submitted, '1234');
      await tester.pumpWidget(const SizedBox.shrink());
    });

    for (final pushedRoute in [false, true]) {
      testWidgets(
        'PIN submit clears keyboard on ${device.size} (route: $pushedRoute)',
        (tester) async {
          String? submitted;
          await showScreen(
            tester,
            PasscodeScreen(
              mode: pushedRoute
                  ? PasscodeScreenMode.setup
                  : PasscodeScreenMode.unlock,
              onBack: () {},
              onSubmit: (code) async {
                submitted = code;
                return null;
              },
            ),
            pushedRoute: pushedRoute,
          );
          await tester.enterText(find.byType(TextField), '1234');
          await openKeyboard(tester);
          await tapAboveKeyboard(tester, find.byType(ElevatedButton));
          expect(submitted, '1234');
        },
      );
    }
  }
}
