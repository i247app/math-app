import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/widgets/signup/signup_action_button.dart';
import 'package:numi/features/auth/widgets/signup/signup_field_label.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_choice.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_radio_group.dart';
import 'package:numi/features/auth/widgets/signup/signup_hero_banner.dart';
import 'package:numi/features/auth/widgets/signup/signup_role_selector.dart';
import 'package:numi/features/auth/widgets/signup/signup_section_card.dart';
import 'package:numi/features/auth/widgets/signup/signup_text_field.dart';
import 'package:numi/shared/layouts/screen_frame.dart';

class SignupComposition extends StatelessWidget {
  const SignupComposition({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.role,
    required this.gender,
    required this.usernameErrorText,
    required this.isFormValid,
    required this.isSigningUp,
    required this.onBack,
    required this.onRoleChanged,
    required this.onGenderChanged,
    required this.onContinue,
  });

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final SignupRole? role;
  final SignupGender? gender;
  final String? usernameErrorText;
  final bool isFormValid;
  final bool isSigningUp;
  final VoidCallback onBack;
  final ValueChanged<SignupRole> onRoleChanged;
  final ValueChanged<SignupGender?> onGenderChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 760;
    final tight = size.width < 370;
    final genderChoices = _genderChoicesForRole(role);
    final nameLabelKey = _nameLabelKey(role, gender);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: context.themeColors.pageBackground,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ScreenFrame(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: compact ? 10 : 14),
                  SignupHeroBanner(
                    title: context.getText(AppKeys.signup),
                    titleFontSize: tight
                        ? FontSize.displaySmall
                        : FontSize.displayMedium,
                    onBack: onBack,
                  ),
                  SignupSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignupFieldLabel(
                          label: context.getText(AppKeys.signupRoleLabel),
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        SignupRoleSelector(
                          value: role,
                          onChanged: onRoleChanged,
                        ),
                        const SizedBox(height: 14),
                        SignupFieldLabel(
                          label: context.getText(AppKeys.signupGenderLabel),
                          isRequired: true,
                        ),
                        const SizedBox(height: 6),
                        SignupGenderRadioGroup(
                          key: ValueKey(
                            'signup-gender-${role?.name ?? 'none'}-'
                            '${gender?.name ?? 'none'}',
                          ),
                          value: gender,
                          hintText: context.getText(
                            role == null
                                ? AppKeys.signupGenderSelectRoleHint
                                : AppKeys.signupGenderHint,
                          ),
                          items: genderChoices,
                          onChanged: role == null ? null : onGenderChanged,
                        ),
                        const SizedBox(height: 16),
                        SignupFieldLabel(
                          label: context.getText(nameLabelKey),
                          isRequired: true,
                        ),
                        const SizedBox(height: 6),
                        SignupTextField(
                          controller: usernameController,
                          hintText: context.getText(AppKeys.signupNameHint),
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          errorText: usernameErrorText,
                        ),
                        const SizedBox(height: 16),
                        SignupFieldLabel(
                          label: context.getText(AppKeys.signupEmailLabel),
                        ),
                        const SizedBox(height: 6),
                        SignupTextField(
                          controller: emailController,
                          hintText: context.getText(AppKeys.signupEmailHint),
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: compact ? 20 : 24),
                        SignupActionButton(
                          label: isSigningUp
                              ? context.getText(AppKeys.signingUp)
                              : context.getText(AppKeys.continueLabel),
                          onPressed: isSigningUp || !isFormValid
                              ? null
                              : onContinue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static List<SignupGenderChoice> _genderChoicesForRole(SignupRole? role) {
    return switch (role) {
      SignupRole.student => const [
        SignupGenderChoice(
          value: SignupGender.studentMale,
          labelKey: AppKeys.signupGenderStudentMale,
        ),
        SignupGenderChoice(
          value: SignupGender.studentFemale,
          labelKey: AppKeys.signupGenderStudentFemale,
        ),
      ],
      SignupRole.parent => const [
        SignupGenderChoice(
          value: SignupGender.parentFather,
          labelKey: AppKeys.signupGenderParentFather,
        ),
        SignupGenderChoice(
          value: SignupGender.parentMother,
          labelKey: AppKeys.signupGenderParentMother,
        ),
      ],
      SignupRole.teacher => const [
        SignupGenderChoice(
          value: SignupGender.teacherMale,
          labelKey: AppKeys.signupGenderTeacherMale,
        ),
        SignupGenderChoice(
          value: SignupGender.teacherFemale,
          labelKey: AppKeys.signupGenderTeacherFemale,
        ),
      ],
      null => const [],
    };
  }

  static String _nameLabelKey(SignupRole? role, SignupGender? gender) {
    if (role == SignupRole.parent && gender == SignupGender.parentFather) {
      return AppKeys.signupNameLabelFather;
    }
    if (role == SignupRole.parent && gender == SignupGender.parentMother) {
      return AppKeys.signupNameLabelMother;
    }
    if (role == SignupRole.teacher && gender == SignupGender.teacherMale) {
      return AppKeys.signupNameLabelTeacherMale;
    }
    if (role == SignupRole.teacher && gender == SignupGender.teacherFemale) {
      return AppKeys.signupNameLabelTeacherFemale;
    }

    return AppKeys.signupNameLabel;
  }
}
