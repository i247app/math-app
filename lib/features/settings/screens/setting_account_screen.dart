import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/data/auth_service.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/core/utils/avatar/avatar_picker_service.dart';
import 'package:numi/features/settings/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/widgets/account/account_screen_skeleton.dart';
import 'package:numi/features/settings/widgets/account_details_panel.dart';
import 'package:numi/features/settings/widgets/setting_header.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

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
      final avatarPath = _draftAvatarPath != _snapshotAvatarPath
          ? _draftAvatarPath
          : null;
      final updatedUser = await _authService.updateUser(
        userId: userId,
        name: name,
        phone: settingsNormalizedPhone(_phoneController.text),
        email: settingsEmptyToNull(_emailController.text),
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
