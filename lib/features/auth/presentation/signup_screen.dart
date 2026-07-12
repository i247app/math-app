import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/application/auth_cubit.dart';
import 'package:numi/features/auth/application/auth_state.dart';
import 'package:numi/features/auth/errors/auth_error_messages.dart';
import 'package:numi/features/auth/widgets/signup/signup_action_button.dart';
import 'package:numi/features/auth/widgets/signup/signup_field_label.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_choice.dart';
import 'package:numi/features/auth/widgets/signup/signup_gender_radio_group.dart';
import 'package:numi/features/auth/widgets/signup/signup_role_card.dart';
import 'package:numi/features/auth/widgets/signup/signup_text_field.dart';
import 'package:numi/shared/widgets/screen_frame.dart';
import 'package:numi/shared/widgets/auth_back_button.dart';
import 'package:numi/shared/widgets/page_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.isSigningUp,
  });

  final VoidCallback onBack;
  final void Function(String name, String? email, String role) onContinue;
  final bool isSigningUp;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  String? selectedRole;
  String? selectedGender;

  static const _studentRole = 'STUDENT';
  static const _parentRole = 'PARENT';
  static const _teacherRole = 'TEACHER';
  static const _studentMale = 'student_male';
  static const _studentFemale = 'student_female';
  static const _parentFather = 'parent_father';
  static const _parentMother = 'parent_mother';
  static const _teacherMale = 'teacher_male';
  static const _teacherFemale = 'teacher_female';

  static final RegExp _signupNamePattern = RegExp(
    r'^[A-Za-z0-9À-ÖØ-öø-ỹ]+(?: +[A-Za-z0-9À-ÖØ-öø-ỹ]+)*$',
  );

  static bool _isValidSignupName(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty && _signupNamePattern.hasMatch(normalized);
  }

  static List<SignupGenderChoice> _genderChoicesForRole(String? role) {
    return switch (role) {
      _studentRole => const [
        SignupGenderChoice(
          value: _studentMale,
          labelKey: AppKeys.signupGenderStudentMale,
        ),
        SignupGenderChoice(
          value: _studentFemale,
          labelKey: AppKeys.signupGenderStudentFemale,
        ),
      ],
      _parentRole => const [
        SignupGenderChoice(
          value: _parentFather,
          labelKey: AppKeys.signupGenderParentFather,
        ),
        SignupGenderChoice(
          value: _parentMother,
          labelKey: AppKeys.signupGenderParentMother,
        ),
      ],
      _teacherRole => const [
        SignupGenderChoice(
          value: _teacherMale,
          labelKey: AppKeys.signupGenderTeacherMale,
        ),
        SignupGenderChoice(
          value: _teacherFemale,
          labelKey: AppKeys.signupGenderTeacherFemale,
        ),
      ],
      _ => const [],
    };
  }

  static String _signupNameLabelKey(String? role, String? gender) {
    if (role == _parentRole && gender == _parentFather) {
      return AppKeys.signupNameLabelFather;
    }
    if (role == _parentRole && gender == _parentMother) {
      return AppKeys.signupNameLabelMother;
    }
    if (role == _teacherRole && gender == _teacherMale) {
      return AppKeys.signupNameLabelTeacherMale;
    }
    if (role == _teacherRole && gender == _teacherFemale) {
      return AppKeys.signupNameLabelTeacherFemale;
    }

    return AppKeys.signupNameLabel;
  }

  void _selectRole(String role) {
    setState(() {
      if (selectedRole != role) {
        selectedGender = null;
      }
      selectedRole = role;
    });
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    usernameController.removeListener(_onTextChanged);
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final compact = height < 760;
    final tight = width < 370;

    final role = selectedRole;
    final gender = selectedGender;
    final username = usernameController.text.trim();
    final isUsernameValid = _isValidSignupName(username);
    final isFormValid = isUsernameValid && role != null && gender != null;
    final genderChoices = _genderChoicesForRole(role);
    final nameLabelKey = _signupNameLabelKey(role, gender);

    return BlocBuilder<AuthFlowCubit, AuthFlowState>(
      builder: (context, state) {
        final localUsernameErrorText = username.isNotEmpty && !isUsernameValid
            ? context.getText(AppKeys.signupNameInvalid)
            : null;
        final usernameErrorText =
            localUsernameErrorText ??
            (isSignupUsernameExistsError(state.authError)
                ? context.getText(AppKeys.signupUsernameExists)
                : null);

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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: compact ? 10 : 14),
                      _SignupHeroBanner(
                        title: context.getText(AppKeys.signup),
                        titleFontSize: tight ? 30 : 34,
                        onBack: widget.onBack,
                      ),
                      _SignupSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SignupFieldLabel(
                              label: context.getText(AppKeys.signupRoleLabel),
                              isRequired: true,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SignupRoleCard(
                                    label: context.getText(
                                      AppKeys.signupRoleStudent,
                                    ),
                                    imagePath: 'assets/images/student-icon.png',
                                    isSelected: role == _studentRole,
                                    onTap: () => _selectRole(_studentRole),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SignupRoleCard(
                                    label: context.getText(
                                      AppKeys.signupRoleParent,
                                    ),
                                    imagePath: 'assets/images/parent-icon.png',
                                    isSelected: role == _parentRole,
                                    onTap: () => _selectRole(_parentRole),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SignupRoleCard(
                                    label: context.getText(
                                      AppKeys.signupRoleTeacher,
                                    ),
                                    imagePath: 'assets/images/teacher-icon.png',
                                    isSelected: role == _teacherRole,
                                    onTap: () => _selectRole(_teacherRole),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SignupFieldLabel(
                              label: context.getText(AppKeys.signupGenderLabel),
                              isRequired: true,
                            ),
                            const SizedBox(height: 6),
                            SignupGenderRadioGroup(
                              key: ValueKey(
                                'signup-gender-${role ?? 'none'}-${gender ?? 'none'}',
                              ),
                              value: gender,
                              hintText: context.getText(
                                role == null
                                    ? AppKeys.signupGenderSelectRoleHint
                                    : AppKeys.signupGenderHint,
                              ),
                              items: genderChoices,
                              onChanged: role == null
                                  ? null
                                  : (value) =>
                                        setState(() => selectedGender = value),
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
                              hintText: context.getText(
                                AppKeys.signupEmailHint,
                              ),
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                            ),
                            SizedBox(height: compact ? 20 : 24),
                            SignupActionButton(
                              label: widget.isSigningUp
                                  ? context.getText(AppKeys.signingUp)
                                  : context.getText(AppKeys.continueLabel),
                              onPressed: (widget.isSigningUp || !isFormValid)
                                  ? null
                                  : () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      widget.onContinue(
                                        usernameController.text,
                                        emailController.text,
                                        role,
                                      );
                                    },
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
      },
    );
  }
}

class _SignupSectionCard extends StatelessWidget {
  const _SignupSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SignupHeroBanner extends StatelessWidget {
  const _SignupHeroBanner({
    required this.title,
    required this.titleFontSize,
    required this.onBack,
  });

  final String title;
  final double titleFontSize;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return SizedBox(
      height: 122,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -64,
            right: -64,
            top: -92,
            height: 218,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/signup_screen/clourd_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topRight,
              ),
            ),
          ),
          Positioned(
            right: -18,
            top: 8,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/signup_screen/rocket_transparent.png',
                width: 148,
                height: 122,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: PageHeader(
              scale: 1,
              topInset: 0,
              backgroundColor: Colors.transparent,
              actionWidth: 44,
              horizontalPadding: 20,
              verticalPadding: 8,
              leading: AuthBackButton(onPressed: onBack),
            ),
          ),
          Positioned(
            left: 0,
            top: 76,
            child: Text(
              title,
              style: GoogleFonts.andika(
                color: colors.brandStrong,
                fontSize: titleFontSize,
                fontWeight: FontWeight.w700,
                height: 1.05,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
