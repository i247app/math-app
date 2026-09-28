import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/features/auth/helpers/auth_error_messages.dart';
import 'package:numi/features/auth/models/signup_form_data.dart';
import 'package:numi/features/auth/models/signup_gender.dart';
import 'package:numi/features/auth/models/signup_role.dart';
import 'package:numi/features/auth/widgets/signup/registration_profile_content.dart';

/// Collects profile details after identifier verification, then creates the account.
class RegistrationProfileScreen extends StatefulWidget {
  const RegistrationProfileScreen({
    super.key,
    required this.onBack,
    required this.onContinue,
    required this.isSigningUp,
    this.initialForm,
    this.initialIdentifier,
    this.authError,
  });

  final VoidCallback onBack;
  final ValueChanged<SignupFormData> onContinue;
  final bool isSigningUp;
  final SignupFormData? initialForm;
  final String? initialIdentifier;
  final String? authError;

  @override
  State<RegistrationProfileScreen> createState() =>
      _RegistrationProfileScreenState();
}

class _RegistrationProfileScreenState extends State<RegistrationProfileScreen> {
  final _usernameController = TextEditingController();

  String get _signupIdentifier =>
      (widget.initialIdentifier ?? widget.initialForm?.email ?? '').trim();

  SignupRole? _selectedRole;
  SignupGender? _selectedGender;
  bool _agreedToTerms = false;
  bool _confirmedInformation = false;

  static final RegExp _namePattern = RegExp(
    r'^[A-Za-z0-9À-ÖØ-öø-ỹ]+(?: +[A-Za-z0-9À-ÖØ-öø-ỹ]+)*$',
  );

  @override
  void initState() {
    super.initState();
    final initialForm = widget.initialForm;
    if (initialForm != null) {
      _usernameController.text = initialForm.name;
      _selectedRole = initialForm.role;
      _selectedGender = initialForm.gender;
    }
    _usernameController.addListener(_rebuildForFormInput);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_rebuildForFormInput);
    _usernameController.dispose();
    super.dispose();
  }

  void _rebuildForFormInput() => setState(() {});

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
    if (role == null ||
        gender == null ||
        !_agreedToTerms ||
        !_confirmedInformation) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onContinue(
      SignupFormData(
        name: _usernameController.text,
        email: detectLoginNameKind(_signupIdentifier) == LoginNameKind.email
            ? _signupIdentifier
            : null,
        role: role,
        gender: gender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = _usernameController.text.trim();
    final isUsernameValid = _isValidName(username);
    final identifierKind = detectLoginNameKind(_signupIdentifier);
    final isIdentifierValid =
        identifierKind == LoginNameKind.phone ||
        (identifierKind == LoginNameKind.email &&
            isValidEmailInput(_signupIdentifier));
    final isFormValid =
        isUsernameValid &&
        isIdentifierValid &&
        _selectedRole != null &&
        _selectedGender != null &&
        _agreedToTerms &&
        _confirmedInformation;
    final localUsernameError = username.isNotEmpty && !isUsernameValid
        ? context.getText(AppKeys.signupNameInvalid)
        : null;
    final usernameError =
        localUsernameError ??
        (isSignupUsernameExistsError(widget.authError)
            ? context.getText(AppKeys.signupUsernameExists)
            : null);

    return RegistrationProfileContent(
      usernameController: _usernameController,
      role: _selectedRole,
      gender: _selectedGender,
      agreedToTerms: _agreedToTerms,
      confirmedInformation: _confirmedInformation,
      usernameErrorText: usernameError,
      isFormValid: isFormValid,
      isSigningUp: widget.isSigningUp,
      onBack: widget.onBack,
      onRoleChanged: _selectRole,
      onGenderChanged: (gender) => setState(() => _selectedGender = gender),
      onTermsChanged: (value) => setState(() => _agreedToTerms = value),
      onInformationChanged: (value) =>
          setState(() => _confirmedInformation = value),
      onContinue: _continue,
    );
  }
}
