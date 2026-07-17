import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/auth/errors/auth_error_messages.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/widgets/signup/signup_composition.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.isSigningUp,
    this.authError,
  });

  final VoidCallback onBack;
  final ValueChanged<SignupFormData> onContinue;
  final bool isSigningUp;
  final String? authError;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  SignupRole? _selectedRole;
  SignupGender? _selectedGender;

  static final RegExp _namePattern = RegExp(
    r'^[A-Za-z0-9À-ÖØ-öø-ỹ]+(?: +[A-Za-z0-9À-ÖØ-öø-ỹ]+)*$',
  );

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_rebuildForUsername);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_rebuildForUsername);
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _rebuildForUsername() => setState(() {});

  void _selectRole(SignupRole role) {
    setState(() {
      if (_selectedRole != role) {
        _selectedGender = null;
      }
      _selectedRole = role;
    });
  }

  bool _isValidName(String name) {
    return name.isNotEmpty && _namePattern.hasMatch(name);
  }

  void _continue() {
    final role = _selectedRole;
    final gender = _selectedGender;
    if (role == null || gender == null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onContinue(
      SignupFormData(
        name: _usernameController.text,
        email: _emailController.text,
        role: role,
        gender: gender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = _usernameController.text.trim();
    final isUsernameValid = _isValidName(username);
    final isFormValid =
        isUsernameValid && _selectedRole != null && _selectedGender != null;
    final localUsernameError = username.isNotEmpty && !isUsernameValid
        ? context.getText(AppKeys.signupNameInvalid)
        : null;
    final usernameError =
        localUsernameError ??
        (isSignupUsernameExistsError(widget.authError)
            ? context.getText(AppKeys.signupUsernameExists)
            : null);

    return SignupComposition(
      usernameController: _usernameController,
      emailController: _emailController,
      role: _selectedRole,
      gender: _selectedGender,
      usernameErrorText: usernameError,
      isFormValid: isFormValid,
      isSigningUp: widget.isSigningUp,
      onBack: widget.onBack,
      onRoleChanged: _selectRole,
      onGenderChanged: (gender) => setState(() => _selectedGender = gender),
      onContinue: _continue,
    );
  }
}
