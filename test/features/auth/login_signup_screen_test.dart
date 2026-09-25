import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/controllers/auth_state.dart';
import 'package:numi/features/auth/screens/login_screen.dart';
import 'package:numi/features/auth/screens/signup_screen.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_action_button.dart';
import 'package:numi/features/auth/widgets/auth_entry/auth_entry_view.dart';

void main() {
  testWidgets('login and signup screens share entry UI with distinct actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final lingo = LingoProvider();
    final controller = TextEditingController();
    addTearDown(lingo.dispose);
    addTearDown(controller.dispose);
    var submitCount = 0;
    final bindings = AuthEntryBindings(
      controller: controller,
      region: PhoneRegion.vn,
      showPhoneRegion: true,
      onRegionChanged: (_) {},
      onBack: () {},
      onSubmitIdentifier: () => submitCount++,
      isSubmitting: false,
      isCheckingIdentifier: false,
      canSubmit: true,
      canLoginWithPin: true,
      onLoginWithPin: () {},
      onSwitchEntryMode: () {},
      onIdentifierChanged: (_) {},
    );

    Future<void> showMode(AuthEntryMode mode) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: mode == AuthEntryMode.login
                ? LoginScreen(bindings: bindings)
                : SignupScreen(bindings: bindings),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showMode(AuthEntryMode.login);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
      lingo.lookup(AppKeys.loginNameHint),
    );
    expect(
      tester
          .widget<AuthEntryActionButton>(find.byType(AuthEntryActionButton))
          .label,
      lingo.lookup(AppKeys.login),
    );
    expect(find.text(lingo.lookup(AppKeys.loginWithPin)), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(submitCount, 1);

    await showMode(AuthEntryMode.signup);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.hintText,
      lingo.lookup(AppKeys.signupEmailHint),
    );
    expect(
      tester
          .widget<AuthEntryActionButton>(find.byType(AuthEntryActionButton))
          .label,
      lingo.lookup(AppKeys.signup),
    );
    expect(find.text(lingo.lookup(AppKeys.loginWithPin)), findsNothing);
    await tester.tap(find.byType(ElevatedButton));
    expect(submitCount, 2);
  });
}
