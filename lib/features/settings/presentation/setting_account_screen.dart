part of '../setting_tab.dart';

class _SettingScreenArgs {
  const _SettingScreenArgs({
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    required this.onActivateProfile,
    required this.onRefreshProfiles,
    required this.onProfileSaved,
    required this.scale,
  });

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final VoidCallback onLogout;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final Future<void> Function()? onRefreshProfiles;
  final VoidCallback? onProfileSaved;
  final double scale;
}

class _SettingAccountScreen extends StatefulWidget {
  const _SettingAccountScreen({required this.args});

  final _SettingScreenArgs args;

  @override
  State<_SettingAccountScreen> createState() => _SettingAccountScreenState();
}

class _SettingAccountScreenState extends State<_SettingAccountScreen>
    with SingleTickerProviderStateMixin {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final OtpAuthService _authService = OtpAuthApi();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
    _user = widget.args.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
        _prepareAccount();
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = _SettingTabState._fallbackUsername(user);
    _phoneController.text = _SettingTabState._displayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  Future<void> _prepareAccount() async {
    final initialUser = widget.args.user;
    final userFuture = initialUser != null
        ? Future<LoginUser?>.value(initialUser)
        : _authService.restoreSession();
    await Future<void>.delayed(const Duration(milliseconds: 500));
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

  void _cancelEditing() {
    HapticFeedback.selectionClick();
    setState(() {
      _usernameController.text = _snapshotUsername ?? _usernameController.text;
      _phoneController.text = _snapshotPhone ?? _phoneController.text;
      _emailController.text = _snapshotEmail ?? _emailController.text;
      _localAvatarPath = _snapshotAvatarPath;
      _draftAvatarPath = null;
      _isEditing = false;
      _isSaving = false;
      _isPickingAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveEditing() async {
    final userId = _user?.id;
    if (userId == null || userId <= 0) {
      _showMessage(context.readText(AppKeys.missingAccount));
      return;
    }
    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      _showMessage(context.readText(AppKeys.accountNameRequired));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      final avatarPath =
          _draftAvatarPath != _snapshotAvatarPath ? _draftAvatarPath : null;
      final updatedUser = await _authService.updateUser(
        userId: userId,
        name: name,
        phone: _SettingTabState._normalizedPhone(_phoneController.text),
        email: _SettingTabState._emptyToNull(_emailController.text),
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
      _showMessage(context.readText(AppKeys.accountUpdated));
    } on OtpAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showMessage(context.readText(AppKeys.accountUpdateFailed));
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
      _showMessage(context.readText(AppKeys.imagePickFailed));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _close() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(_didSave);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.args.scale;
    final screen = PopScope(
      canPop: !_isSaving,
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
                backgroundColor: Colors.white,
                scale: scale,
                topInset: 0,
              ),
              SizedBox(height: 36 * scale),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: _isLoadingAccount
                    ? AccountScreenSkeleton(scale: scale)
                    : AccountDetailsPanel(
                        avatarUrl: _user?.avatarUrl,
                        avatarPath:
                            _isEditing ? _draftAvatarPath : _localAvatarPath,
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
                        scale: scale,
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
        final scale = Curves.easeOutCubic.transform(
          _entranceController.value,
        );
        return Transform.scale(
          scale: 0.97 + 0.03 * scale,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
