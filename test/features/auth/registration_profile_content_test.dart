import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/localization/app_keys.dart';
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

    final action = tester.widget<SignupActionButton>(
      find.byType(SignupActionButton),
    );
    expect(action.onPressed, isNotNull);
    await tester.tap(find.byType(SignupActionButton));
    expect(submittedForm?.name, 'Learner');
    expect(submittedForm?.email, isNull);
  });

  testWidgets('Create User action says Sign up, then Signing up', (
    tester,
  ) async {
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
              usernameErrorText: null,
              isFormValid: false,
              isSigningUp: isSigningUp,
              onBack: () {},
              onRoleChanged: (_) {},
              onGenderChanged: (_) {},
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
    expect(find.text(lingo.lookup(AppKeys.signup)), findsOneWidget);

    await showContent(isSigningUp: true);
    expect(
      tester.widget<SignupActionButton>(find.byType(SignupActionButton)).label,
      lingo.lookup(AppKeys.signingUp),
    );
  });
}
