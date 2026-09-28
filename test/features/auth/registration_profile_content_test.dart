import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/screens/registration_profile_screen.dart';
import 'package:numi/features/auth/widgets/signup/registration_profile_content.dart';
import 'package:numi/features/auth/widgets/signup/signup_action_button.dart';

void main() {
  testWidgets('Create User accepts a verified phone identifier', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lingo = LingoProvider();
    addTearDown(lingo.dispose);
    SignupFormData? submittedForm;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
        ),
        home: LingoScope(
          lingo: lingo,
          child: RegistrationProfileScreen(
            onBack: () {},
            onContinue: (form) => submittedForm = form,
            isSigningUp: false,
            initialIdentifier: '+84905666666',
            initialForm: const SignupFormData(
              name: 'Learner',
              role: SignupRole.student,
              gender: SignupGender.studentMale,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final terms = find.byKey(const ValueKey('signup-terms-consent'));
    final accuracy = find.byKey(const ValueKey('signup-accuracy-confirmation'));
    expect(
      find.text('Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật.'),
      findsOneWidget,
    );
    expect(
      find.text('Tôi xác nhận thông tin đăng ký là chính xác.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SignupActionButton>(find.byType(SignupActionButton))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SignupActionButton>(find.byType(SignupActionButton))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(accuracy);
    await tester.tap(accuracy);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SignupActionButton>(find.byType(SignupActionButton))
          .onPressed,
      isNotNull,
    );
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SignupActionButton>(find.byType(SignupActionButton))
          .onPressed,
      isNull,
    );
    await tester.tap(terms);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SignupActionButton));
    await tester.tap(find.byType(SignupActionButton));
    expect(submittedForm?.name, 'Learner');
    expect(submittedForm?.email, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create User action says Sign up, then Signing up', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    final lingo = LingoProvider();
    final nameController = TextEditingController();
    addTearDown(lingo.dispose);
    addTearDown(nameController.dispose);

    Future<void> showContent({required bool isSigningUp}) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[AppThemeColors.light],
          ),
          home: LingoScope(
            lingo: lingo,
            child: RegistrationProfileContent(
              usernameController: nameController,
              role: null,
              gender: null,
              agreedToTerms: false,
              confirmedInformation: false,
              usernameErrorText: null,
              isFormValid: false,
              isSigningUp: isSigningUp,
              onBack: () {},
              onRoleChanged: (_) {},
              onGenderChanged: (_) {},
              onTermsChanged: (_) {},
              onInformationChanged: (_) {},
              onContinue: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await showContent(isSigningUp: false);
    expect(
      tester.widget<SignupActionButton>(find.byType(SignupActionButton)).label,
      lingo.lookup(AppKeys.signup),
    );
    expect(
      find.text(lingo.lookup(AppKeys.signup).toUpperCase()),
      findsOneWidget,
    );
    expect(
      find.text('Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật.'),
      findsOneWidget,
    );
    expect(
      find.text('Tôi xác nhận thông tin đăng ký là chính xác.'),
      findsOneWidget,
    );

    await lingo.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(
      find.text('I agree to the Terms of Use and Privacy Policy.'),
      findsOneWidget,
    );
    expect(
      find.text('I confirm that my registration information is accurate.'),
      findsOneWidget,
    );

    await showContent(isSigningUp: true);
    expect(
      tester.widget<SignupActionButton>(find.byType(SignupActionButton)).label,
      lingo.lookup(AppKeys.signingUp),
    );
    expect(
      find.text(lingo.lookup(AppKeys.signingUp).toUpperCase()),
      findsOneWidget,
    );
  });
}
