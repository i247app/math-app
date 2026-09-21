import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/auth/widgets/auth_digit_box.dart';
import 'package:numi/core/utils/avatar/avatar_picker_service.dart';
import 'package:numi/features/settings/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/widgets/account/account_screen_skeleton.dart';
import 'package:numi/features/settings/widgets/account_details_panel.dart';
import 'package:numi/features/settings/widgets/setting_header.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';
import 'package:numi/shared/controllers/numeric_code_input_controller.dart';

class SettingAccountScreen extends StatefulWidget {
  const SettingAccountScreen({super.key, required this.args});

  final SettingScreenArgs args;

  @override
  State<SettingAccountScreen> createState() => _SettingAccountScreenState();
}

class _SettingAccountScreenState extends State<SettingAccountScreen>
    with SingleTickerProviderStateMixin {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  late final AuthService _authService;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GuardedExitController<bool> _exitController =
      GuardedExitController<bool>();

  LoginUser? _user;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isPickingAvatar = false;
  bool _isLoadingAccount = true;
  bool _didSave = false;
  String? _localAvatarPath;
  String? _draftAvatarPath;
  String? _snapshotUsername;
  String? _snapshotPhone;
  String? _snapshotEmail;
  String? _snapshotAvatarPath;
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 0,
  );

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _usernameController.addListener(_onDraftChanged);
    _phoneController.addListener(_onDraftChanged);
    _emailController.addListener(_onDraftChanged);
    _user = widget.args.user;
    if (_user != null) {
      _applyUser(_user);
      _isLoadingAccount = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
        if (_user == null) {
          _prepareAccount();
        }
      }
    });
  }

  @override
  void dispose() {
    _usernameController
      ..removeListener(_onDraftChanged)
      ..dispose();
    _phoneController
      ..removeListener(_onDraftChanged)
      ..dispose();
    _emailController
      ..removeListener(_onDraftChanged)
      ..dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = user?.name?.trim() ?? '';
    _phoneController.text = settingsDisplayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  Future<void> _prepareAccount() async {
    final initialUser = widget.args.user;
    final userFuture = initialUser != null
        ? Future<LoginUser?>.value(initialUser)
        : _authService.restoreSession();
    try {
      final user = await userFuture;
      if (!mounted) {
        return;
      }
      setState(() {
        _user = user;
        _applyUser(user);
        _isLoadingAccount = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingAccount = false);
      }
    }
  }

  void _startEditing() {
    HapticFeedback.selectionClick();
    setState(() {
      _snapshotUsername = _usernameController.text;
      _snapshotPhone = _phoneController.text;
      _snapshotEmail = _emailController.text;
      _snapshotAvatarPath = _localAvatarPath;
      _draftAvatarPath = _localAvatarPath;
      _isEditing = true;
    });
  }

  void _onDraftChanged() {
    if (mounted && _isEditing) {
      setState(() {});
    }
  }

  bool get _hasUnsavedChanges {
    if (!_isEditing) {
      return false;
    }
    return _usernameController.text != _snapshotUsername ||
        _phoneController.text != _snapshotPhone ||
        _emailController.text != _snapshotEmail ||
        _draftAvatarPath != _snapshotAvatarPath;
  }

  void _cancelEditing() {
    HapticFeedback.selectionClick();
    setState(() {
      // Disable draft tracking before restoring controller values because
      // controller listeners run synchronously.
      _isEditing = false;
      _usernameController.text = _snapshotUsername ?? _usernameController.text;
      _phoneController.text = _snapshotPhone ?? _phoneController.text;
      _emailController.text = _snapshotEmail ?? _emailController.text;
      _localAvatarPath = _snapshotAvatarPath;
      _draftAvatarPath = null;
      _isSaving = false;
      _isPickingAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveEditing() async {
    final userId = _user?.id;
    if (userId == null || userId <= 0) {
      _showError(context.readText(AppKeys.missingAccount));
      return;
    }
    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      _showError(context.readText(AppKeys.accountNameRequired));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      final email = settingsEmptyToNull(_emailController.text);
      if (_isNewEmail(email)) {
        await _authService.sendOtp(
          loginName: email!,
          // The OTP API currently exposes REGISTER and LOGIN_2FA only. The
          // REGISTER OTP verifies ownership of the new email address.
          kind: AuthOtpKind.signup,
        );
        if (!mounted) {
          return;
        }

        final verified = await _showEmailOtpVerification(email);
        if (!mounted) {
          return;
        }
        if (!verified) {
          setState(() => _isSaving = false);
          return;
        }
      }

      final avatarPath = _draftAvatarPath != _snapshotAvatarPath
          ? _draftAvatarPath
          : null;
      final updatedUser = await _authService.updateUser(
        userId: userId,
        name: name,
        phone: settingsNormalizedPhone(_phoneController.text),
        email: email,
        avatarPath: avatarPath,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _user = updatedUser;
        _localAvatarPath = _draftAvatarPath;
        _draftAvatarPath = null;
        _isEditing = false;
        _isPickingAvatar = false;
        _isSaving = false;
        _didSave = true;
      });
      FocusScope.of(context).unfocus();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showError(context.readText(AppKeys.accountUpdateFailed));
    }
  }

  bool _isNewEmail(String? email) {
    final currentEmail = _user?.email?.trim();
    return email != null && email.toLowerCase() != currentEmail?.toLowerCase();
  }

  Future<bool> _showEmailOtpVerification(String email) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _EmailOtpVerificationDialog(
            email: email,
            authService: _authService,
          ),
        ) ??
        false;
  }

  Future<void> _pickAvatar() async {
    if (!_isEditing || _isPickingAvatar) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _isPickingAvatar = true);
    try {
      final path = await _avatarPicker.pickAvatarPath();
      if (!mounted) {
        return;
      }
      setState(() {
        if (path != null) {
          _draftAvatarPath = path;
        }
        _isPickingAvatar = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isPickingAvatar = false);
      _showError(context.readText(AppKeys.imagePickFailed));
    }
  }

  void _showError(String message) {
    context.showErrorDialog(message);
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    _exitController.requestExit();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.args.scale;
    final screen = GuardedExitScope<bool>(
      controller: _exitController,
      shouldConfirm: _hasUnsavedChanges,
      isExitBlocked: _isSaving || _isPickingAvatar,
      confirmExit: showUnsavedChangesExitDialog,
      exitResult: _didSave,
      child: SettingSafeScreen(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingHeader(
                title: context.getText(AppKeys.accountTitle),
                canGoBack: true,
                onBack: _close,
                backgroundColor: context.themeColors.elevatedSurface,
                topInset: 0,
              ),
              SizedBox(height: 36 * scale),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: _isLoadingAccount
                    ? const AccountScreenSkeleton()
                    : AccountDetailsPanel(
                        avatarUrl: _user?.avatarUrl,
                        avatarPath: _isEditing
                            ? _draftAvatarPath
                            : _localAvatarPath,
                        usernameController: _usernameController,
                        phoneController: _phoneController,
                        emailController: _emailController,
                        isEditing: _isEditing,
                        isSaving: _isSaving,
                        isPickingAvatar: _isPickingAvatar,
                        onEdit: _startEditing,
                        onSave: _saveEditing,
                        onCancel: _cancelEditing,
                        onAvatarTap: _pickAvatar,
                      ),
              ),
              SizedBox(height: 24 * scale),
            ],
          ),
        ),
      ),
    );
    return AnimatedBuilder(
      animation: _entranceController,
      child: screen,
      builder: (context, child) {
        final scale = Curves.easeOutCubic.transform(_entranceController.value);
        return Transform.scale(
          scale: 0.97 + 0.03 * scale,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}

class _EmailOtpVerificationDialog extends StatefulWidget {
  const _EmailOtpVerificationDialog({
    required this.email,
    required this.authService,
  });

  final String email;
  final AuthService authService;

  @override
  State<_EmailOtpVerificationDialog> createState() =>
      _EmailOtpVerificationDialogState();
}

class _EmailOtpVerificationDialogState
    extends State<_EmailOtpVerificationDialog> {
  late final NumericCodeInputController _codeInput = NumericCodeInputController(
    length: 4,
  );
  bool _isVerifying = false;
  String? _error;

  @override
  void dispose() {
    _codeInput.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_codeInput.isComplete || _isVerifying) {
      return;
    }
    final code = _codeInput.value;

    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      final result = await widget.authService.verifyOtp(
        loginName: widget.email,
        otpCode: code,
        kind: AuthOtpKind.signup,
      );
      if (!mounted) {
        return;
      }
      if (result.isValid) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _isVerifying = false;
        _error = result.message ?? context.readText(AppKeys.invalidOtp);
      });
    } on AuthException catch (error) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _error = context.readText(AppKeys.verifyOtpFailed);
        });
      }
    }
  }

  void _updateDigit(int index, String value) {
    _codeInput.updateDigit(index, value);
    setState(() => _error = null);
  }

  void _handleEmptyBackspace(int index) {
    _codeInput.clearPreviousAndFocus(index);
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isVerifying,
      child: AlertDialog(
        title: Text(context.getText(AppKeys.accountEmailVerificationTitle)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.formatText(AppKeys.accountEmailVerificationMessage, {
                'email': widget.email,
              }),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: context.getText(AppKeys.accountEmailVerificationCodeHint),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                      child: SizedBox(
                        height: 58,
                        child: AuthDigitBox.otp(
                          controller: _codeInput.controllers[index],
                          focusNode: _codeInput.focusNodes[index],
                          autofocus: index == 0,
                          textInputAction: index == 3
                              ? TextInputAction.done
                              : TextInputAction.next,
                          onChanged: (value) => _updateDigit(index, value),
                          onEmptyBackspace: () => _handleEmptyBackspace(index),
                          hasError: _error != null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isVerifying
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(context.getText(AppKeys.cancel)),
          ),
          FilledButton(
            onPressed: _isVerifying || !_codeInput.isComplete ? null : _verify,
            child: _isVerifying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.getText(AppKeys.otpConfirm)),
          ),
        ],
      ),
    );
  }
}
