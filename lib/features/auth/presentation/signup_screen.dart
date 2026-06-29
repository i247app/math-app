import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/theme/app_colors.dart';
import 'package:numi_flutter/features/auth/auth_cubit.dart';
import 'package:numi_flutter/features/auth/auth_state.dart';
import 'package:numi_flutter/shared/widgets/common_widgets.dart';

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

  static final RegExp _signupNamePattern = RegExp(
    r'^[A-Za-z0-9À-ÖØ-öø-ỹ]+(?: +[A-Za-z0-9À-ÖØ-öø-ỹ]+)*$',
  );

  static bool _isUsernameExistsError(String? message) {
    final normalized = message?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }

    return normalized.contains('username already exists');
  }

  static bool _isValidSignupName(String value) {
    final normalized = value.trim();
    return normalized.isNotEmpty && _signupNamePattern.hasMatch(normalized);
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
    final mascotSize = tight ? 118.0 : 136.0;

    final role = selectedRole;
    final username = usernameController.text.trim();
    final isUsernameValid = _isValidSignupName(username);
    final isFormValid = isUsernameValid && role != null;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.avatarError != current.avatarError &&
          current.avatarError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.avatarError!)));
      },
      builder: (context, state) {
        final localUsernameErrorText = username.isNotEmpty && !isUsernameValid
            ? context.getText(AppKeys.signupNameInvalid)
            : null;
        final usernameErrorText =
            localUsernameErrorText ??
            (_isUsernameExistsError(state.authError) ? state.authError : null);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: ScreenFrame(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: widget.onBack,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            context.getText(AppKeys.signup),
                            style: GoogleFonts.andika(
                              color: const Color(0xFF339395),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 52), // To balance the back button
                    ],
                  ),
                  SizedBox(height: compact ? 14 : 24),
                  // Mascot
                  Center(
                    child: Container(
                      width: mascotSize,
                      height: mascotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/numi-mascot.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 20 : 30),
                  // Inputs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignupFieldLabel(
                          label: context.getText(AppKeys.signupNameLabel),
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        SignupTextField(
                          controller: usernameController,
                          hintText: context.getText(AppKeys.signupNameHint),
                          textInputAction: TextInputAction.next,
                          errorText: usernameErrorText,
                        ),
                        const SizedBox(height: 20),
                        SignupFieldLabel(
                          label: context.getText(AppKeys.signupEmailLabel),
                        ),
                        const SizedBox(height: 8),
                        SignupTextField(
                          controller: emailController,
                          hintText: context.getText(AppKeys.signupEmailHint),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: compact ? 24 : 28),
                        // Roles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _RoleCard(
                                label: context.getText(
                                  AppKeys.signupRoleStudent,
                                ),
                                imagePath: 'assets/images/student-icon.png',
                                isSelected: role == 'STUDENT',
                                onTap: () =>
                                    setState(() => selectedRole = 'STUDENT'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RoleCard(
                                label: context.getText(
                                  AppKeys.signupRoleParent,
                                ),
                                imagePath: 'assets/images/parent-icon.png',
                                isSelected: role == 'PARENT',
                                onTap: () =>
                                    setState(() => selectedRole = 'PARENT'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RoleCard(
                                label: context.getText(
                                  AppKeys.signupRoleTeacher,
                                ),
                                imagePath: 'assets/images/teacher-icon.png',
                                isSelected: role == 'TEACHER',
                                onTap: () =>
                                    setState(() => selectedRole = 'TEACHER'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 32 : 54),
                        _TealActionButton(
                          label: widget.isSigningUp
                              ? context.getText(AppKeys.signingUp)
                              : context.getText(AppKeys.continueLabel),
                          onPressed: (widget.isSigningUp || !isFormValid)
                              ? null
                              : () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  widget.onContinue(
                                    usernameController.text,
                                    emailController.text,
                                    role,
                                  );
                                },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SignupFieldLabel extends StatelessWidget {
  const SignupFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.andika(
          color: const Color(0xFF1B1B1B),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFE74657)),
            ),
        ],
      ),
    );
  }
}

class SignupTextField extends StatelessWidget {
  const SignupTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 58,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: null,
            enableSuggestions: true,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.andika(
                color: const Color(0xFF7E9088),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE7E7E7),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE7E7E7),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF339395),
                  width: 2,
                ),
              ),
            ),
            style: GoogleFonts.andika(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              errorText!,
              style: GoogleFonts.andika(
                color: const Color(0xFFE74657),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF339395) : Colors.transparent,
            width: 2.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: Image.asset(imagePath, fit: BoxFit.contain)),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TealActionButton extends StatelessWidget {
  const _TealActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll('→', '').trim();

    return Center(
      child: SizedBox(
        width: 230,
        height: 58,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF339395), // Teal from design
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            disabledBackgroundColor: const Color(
              0xFFB5BFC2,
            ), // Grey when disabled
            disabledForegroundColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                cleanLabel,
                style: GoogleFonts.andika(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
