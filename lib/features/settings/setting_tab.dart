import 'package:numi/features/settings/settings_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/app/numi_app.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/profile_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/semester_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/core/utils/avatar/avatar_picker_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/profile_management_cubit.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_exception.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/profile/models/profile_role.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/features/auth/presentation/passcode_screen.dart';
import 'package:numi/shared/widgets/loading_screen.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';
import 'package:numi/features/settings/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/presentation/setting_account_screen.dart';
import 'package:numi/features/settings/widgets/account_details_panel.dart';
import 'package:numi/features/profile/widgets/profile_form_panel.dart';
import 'package:numi/features/profile/widgets/profile_list_panel.dart';
import 'package:numi/features/settings/widgets/setting_header.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';
import 'package:numi/features/settings/widgets/menu/passcode_settings_sheet.dart';
import 'package:numi/features/settings/widgets/settings_menu_panel.dart';

enum SettingPageView { settings, account, profile, addProfile }

class _SettingsDepthRoute<T> extends PageRouteBuilder<T> {
  _SettingsDepthRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 380),
        opaque: false,
        allowSnapshotting: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final isReversing = animation.status == AnimationStatus.reverse;
              final progress =
                  (isReversing ? Curves.easeInCubic : Curves.easeOutCubic)
                      .transform(animation.value);
              if (isReversing) {
                return Opacity(opacity: progress, child: child);
              }
              return child ?? const SizedBox.shrink();
            },
          );
        },
      );

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      _buildDelegatedTransition;

  static Widget? _buildDelegatedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    return AnimatedBuilder(
      animation: secondaryAnimation,
      child: child,
      builder: (context, child) {
        final isReversing =
            secondaryAnimation.status == AnimationStatus.reverse;
        final progress =
            (isReversing ? Curves.easeInCubic : Curves.easeOutCubic).transform(
              secondaryAnimation.value,
            );
        if (isReversing) {
          return ColoredBox(
            color: context.themeColors.pageBackground,
            child: Transform.scale(
              scale: 1 + (0.14 * progress),
              alignment: Alignment.center,
              child: child,
            ),
          );
        }

        return ColoredBox(
          color: context.themeColors.pageBackground,
          child: Transform.scale(
            scale: 1 - (0.12 * progress),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

class SettingTab extends StatefulWidget {
  const SettingTab({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    required this.onActivateProfile,
    this.onRefreshProfiles,
    this.onProfileSaved,
    this.openAddProfileRequestId = 0,
    required this.bottomPadding,
    required this.scale,
    this.isActive = true,
  }) : _initialView = SettingPageView.settings,
       _initialEditingProfile = null,
       _isPushedPage = false,
       _openAddProfileOnStart = false;

  const SettingTab.page({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    required this.onActivateProfile,
    this.onRefreshProfiles,
    this.onProfileSaved,
    required this.bottomPadding,
    required this.scale,
    SettingPageView initialView = SettingPageView.settings,
    StudentProfile? initialEditingProfile,
    bool isPushedPage = false,
    bool openAddProfileOnStart = false,
    this.isActive = true,
  }) : openAddProfileRequestId = 0,
       _initialView = initialView,
       _initialEditingProfile = initialEditingProfile,
       _isPushedPage = isPushedPage,
       _openAddProfileOnStart = openAddProfileOnStart;

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final VoidCallback onLogout;
  final Future<void> Function(StudentProfile profile) onActivateProfile;
  final Future<void> Function()? onRefreshProfiles;
  final VoidCallback? onProfileSaved;
  final int openAddProfileRequestId;
  final double bottomPadding;
  final double scale;
  final bool isActive;
  final SettingPageView _initialView;
  final StudentProfile? _initialEditingProfile;
  final bool _isPushedPage;
  final bool _openAddProfileOnStart;

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final AuthService _authService = AuthApi();
  final PasscodeService _passcodeService = const SecurePasscodeService();
  final ProfileService _profileService = ProfileApi();
  final GradeService _gradeService = GradeApi();
  final SchoolService _schoolService = SchoolApi();
  final ActiveProfileSession _activeProfileSession =
      const ActiveProfileSession();
  late final ProfileManagementCubit _profileManagementCubit;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profilePhoneController = TextEditingController();
  final TextEditingController _profileEmailController = TextEditingController();
  final TextEditingController _profileIdController = TextEditingController();

  late SettingPageView _view;
  bool _isForwardTransition = true;
  bool _isEditing = false;
  bool _isSavingAccount = false;
  bool _isPickingAccountAvatar = false;
  bool _isLoadingProfiles = false;
  bool _isLoadingProfileOptions = false;
  bool _isSavingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isDeletingProfile = false;
  bool _isSettingDefaultProfile = false;
  bool _isSwitchingProfile = false;
  bool _isChangingLanguage = false;
  bool _isLoadingPasscode = false;
  bool _hasPasscode = false;
  bool _hasPlayedSettingsMenuEntrance = false;
  bool _isPasscodeStatusLoadScheduled = false;
  String? _profileLoadError;
  String? _profileOptionsError;
  String? _profileCreateError;
  String? _localAvatarPath;
  String? _draftAvatarPath;
  String? _selectedProfileAvatarKey;
  String? _snapshotUsername;
  String? _snapshotPhone;
  String? _snapshotEmail;
  String? _snapshotAvatarPath;
  LoginUser? _updatedUser;
  StudentProfile? _editingProfile;
  List<StudentProfile> _profiles = const <StudentProfile>[];
  List<SchoolModel> _schoolOptions = const <SchoolModel>[];
  List<GradeModel> _gradeOptions = const <GradeModel>[];
  List<ProgramModel> _programOptions = const <ProgramModel>[];
  List<SemesterModel> _semesterOptions = const <SemesterModel>[];
  SchoolModel? _selectedSchool;
  GradeModel? _selectedGrade;
  ProgramModel? _selectedProgram;
  SemesterModel? _selectedSemester;
  String? _selectedProfileIdType;
  int? _localActiveProfileId;

  @override
  void initState() {
    super.initState();
    _profileManagementCubit = ProfileManagementCubit(
      profileService: _profileService,
      gradeService: _gradeService,
      schoolService: _schoolService,
      activeProfileSession: _activeProfileSession,
    );
    _profileNameController.addListener(_onProfileNameChanged);
    _view = widget._initialView;
    _applyUser(widget.user);
    _profiles = widget.profiles;
    _localActiveProfileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    _profileLoadError = widget.profileLoadError;
    final initialEditingProfile = widget._initialEditingProfile;
    if (initialEditingProfile != null) {
      _editingProfile = initialEditingProfile;
      _profileNameController.text = initialEditingProfile.name?.trim() ?? '';
      _selectedProfileAvatarKey = initialEditingProfile.avatarKey?.trim();
      if (_profileRole(initialEditingProfile) == 'PARENT') {
        _applyParentContactFields();
      } else {
        _applyProfileIdFields(initialEditingProfile);
      }
    }
    if (_view == SettingPageView.profile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _loadProfiles();
        _preloadProfileOptions();
        if (widget._openAddProfileOnStart) {
          _openAddProfile();
        }
      });
    } else if (_view == SettingPageView.addProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final isEditingParent =
            initialEditingProfile != null &&
            _profileRole(initialEditingProfile) == 'PARENT';
        if (initialEditingProfile != null && !isEditingParent) {
          _selectOptionsForProfile(initialEditingProfile);
        } else if (initialEditingProfile == null) {
          _resetCreateProfileForm();
        }
        if (!isEditingParent && !_hasProfileOptions) {
          _loadProfileOptions(profileToSelect: initialEditingProfile);
        }
      });
    }
    if (widget.openAddProfileRequestId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openAddProfile();
        }
      });
    }
    _schedulePasscodeStatusLoad();
  }

  @override
  void didUpdateWidget(covariant SettingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _schedulePasscodeStatusLoad();
    }
    if (oldWidget.openAddProfileRequestId != widget.openAddProfileRequestId) {
      _openAddProfile();
      return;
    }

    if (oldWidget.user != widget.user && !_isEditing) {
      _updatedUser = null;
      _applyUser(widget.user);
      _profiles = widget.profiles;
      _schoolOptions = const <SchoolModel>[];
      _gradeOptions = const <GradeModel>[];
      _programOptions = const <ProgramModel>[];
      _semesterOptions = const <SemesterModel>[];
      _selectedSchool = null;
      _selectedGrade = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _profileLoadError = widget.profileLoadError;
      _profileOptionsError = null;
      if (_view == SettingPageView.profile) {
        _loadProfiles();
        _preloadProfileOptions();
      }
    }

    if (oldWidget.profiles != widget.profiles) {
      _profiles = widget.profiles;
    }

    if (oldWidget.activeProfile != widget.activeProfile) {
      _localActiveProfileId = ActiveProfileSession.profileStableId(
        widget.activeProfile,
      );
    }

    if (oldWidget.profileLoadError != widget.profileLoadError) {
      _profileLoadError = widget.profileLoadError;
    }

    if (oldWidget.user?.id != widget.user?.id) {
      _schedulePasscodeStatusLoad();
    }
  }

  @override
  void dispose() {
    _profileManagementCubit.close();
    _profileNameController.removeListener(_onProfileNameChanged);
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _profileNameController.dispose();
    _profilePhoneController.dispose();
    _profileEmailController.dispose();
    _profileIdController.dispose();
    super.dispose();
  }

  void _onProfileNameChanged() {
    if (!mounted || _view != SettingPageView.addProfile) {
      return;
    }
    setState(() {});
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = settingsFallbackUsername(user);
    _phoneController.text = settingsDisplayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  LoginUser? get _effectiveUser => _updatedUser ?? widget.user;

  int? get _effectiveUserId {
    final userId = _effectiveUser?.id;
    return userId != null && userId > 0 ? userId : null;
  }

  void _schedulePasscodeStatusLoad() {
    if (_isPasscodeStatusLoadScheduled) {
      return;
    }

    _isPasscodeStatusLoadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isPasscodeStatusLoadScheduled = false;
      if (!mounted || !widget.isActive) {
        return;
      }
      _loadPasscodeStatus();
    });
  }

  Future<void> _loadPasscodeStatus() async {
    final userId = _effectiveUserId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _hasPasscode = false;
          _isLoadingPasscode = false;
        });
      }
      return;
    }

    setState(() => _isLoadingPasscode = true);
    final hasPasscode = await _passcodeService.hasPasscode(userId);
    if (!mounted || _effectiveUserId != userId) {
      return;
    }
    setState(() {
      _hasPasscode = hasPasscode;
      _isLoadingPasscode = false;
    });
  }

  Future<void> _openPasscodeSettings() async {
    HapticFeedback.selectionClick();
    final userId = _effectiveUserId;
    if (userId == null || _isLoadingPasscode) {
      return;
    }

    if (!_hasPasscode) {
      await _setPasscode(userId);
      return;
    }

    final action = await showModalBottomSheet<PasscodeSettingsAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return PasscodeSettingsSheet(
          scale: widget.scale,
          onChange: () =>
              Navigator.of(sheetContext).pop(PasscodeSettingsAction.change),
          onRemove: () =>
              Navigator.of(sheetContext).pop(PasscodeSettingsAction.remove),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case PasscodeSettingsAction.change:
        await _changePasscode(userId);
      case PasscodeSettingsAction.remove:
        await _removePasscode(userId);
    }
  }

  Future<void> _setPasscode(int userId) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.createPasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await _passcodeService.setPasscode(
                userId: userId,
                passcode: passcode,
              );
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );

    if (!mounted || saved != true) {
      return;
    }
    setState(() => _hasPasscode = true);
  }

  Future<void> _changePasscode(int userId) async {
    final verified = await _verifyCurrentPasscode(
      userId: userId,
      titleKey: AppKeys.enterCurrentPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeContinue,
    );
    if (!mounted || !verified) {
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.setup,
            titleKey: AppKeys.changePasscodeTitle,
            primaryLabelKey: AppKeys.passcodeContinue,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              await _passcodeService.setPasscode(
                userId: userId,
                passcode: passcode,
              );
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );

    if (!mounted || changed != true) {
      return;
    }
    setState(() => _hasPasscode = true);
  }

  Future<void> _removePasscode(int userId) async {
    final verified = await _verifyCurrentPasscode(
      userId: userId,
      titleKey: AppKeys.verifyPasscodeTitle,
      primaryLabelKey: AppKeys.passcodeRemove,
    );
    if (!mounted || !verified) {
      return;
    }

    try {
      await _passcodeService.clearPasscode(userId);
      if (!mounted) {
        return;
      }
      setState(() => _hasPasscode = false);
    } catch (_) {
      _showError(AppKeys.passcodeRemoveFailed);
    }
  }

  Future<bool> _verifyCurrentPasscode({
    required int userId,
    required String titleKey,
    required String primaryLabelKey,
  }) async {
    final incorrectMessage = context.getText(AppKeys.passcodeIncorrect);
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (routeContext) {
          return PasscodeScreen(
            mode: PasscodeScreenMode.verify,
            titleKey: titleKey,
            primaryLabelKey: primaryLabelKey,
            onBack: () => Navigator.of(routeContext).pop(false),
            onSubmit: (passcode) async {
              final isValid = await _passcodeService.verifyPasscode(
                userId: userId,
                passcode: passcode,
              );
              if (!isValid) {
                return incorrectMessage;
              }
              if (routeContext.mounted) {
                Navigator.of(routeContext).pop(true);
              }
              return null;
            },
          );
        },
      ),
    );
    return verified == true;
  }

  void _showError(String messageKey) {
    if (!mounted) {
      return;
    }
    context.showErrorDialog(context.getText(messageKey));
  }

  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  }) async {
    if (view != SettingPageView.account) {
      HapticFeedback.selectionClick();
    }
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    _isEditing = false;
    _isPickingAccountAvatar = false;
    _draftAvatarPath = null;
    FocusScope.of(context).unfocus();

    final screen = _settingScreenForView(
      view,
      editingProfile,
      openAddProfileOnStart: openAddProfileOnStart,
    );
    final route = view == SettingPageView.account
        ? _SettingsDepthRoute<bool>(builder: (_) => screen)
        : MaterialPageRoute<bool>(builder: (_) => screen);
    final didSave = await Navigator.of(context).push<bool>(route);

    if (!mounted) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await _loadProfiles();
    if (didSave == true) {
      widget.onProfileSaved?.call();
    }
  }

  Widget _settingScreenForView(
    SettingPageView view,
    StudentProfile? editingProfile, {
    bool openAddProfileOnStart = false,
  }) {
    final args = SettingScreenArgs(
      user: widget.user,
      profiles: _profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: _profileLoadError,
      onLogout: widget.onLogout,
      onActivateProfile: widget.onActivateProfile,
      onRefreshProfiles: widget.onRefreshProfiles,
      onProfileSaved: widget.onProfileSaved,
      scale: widget.scale,
    );

    return switch (view) {
      SettingPageView.account => SettingAccountScreen(args: args),
      SettingPageView.profile => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: args.onProfileSaved,
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.profile,
          isPushedPage: true,
          openAddProfileOnStart: openAddProfileOnStart,
        ),
      ),
      SettingPageView.addProfile => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: () => Navigator.of(context).pop(true),
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.addProfile,
          initialEditingProfile: editingProfile,
          isPushedPage: true,
        ),
      ),
      SettingPageView.settings => SettingSafeScreen(
        child: SettingTab.page(
          user: args.user,
          profiles: args.profiles,
          activeProfile: args.activeProfile,
          profileLoadError: args.profileLoadError,
          onLogout: args.onLogout,
          onActivateProfile: args.onActivateProfile,
          onRefreshProfiles: args.onRefreshProfiles,
          onProfileSaved: args.onProfileSaved,
          bottomPadding: 0,
          scale: args.scale,
          initialView: SettingPageView.profile,
          isPushedPage: true,
        ),
      ),
    };
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    if (_isChangingLanguage) {
      return;
    }

    final lingo = LingoScope.read(context);
    if (lingo.language == language) {
      return;
    }

    setState(() => _isChangingLanguage = true);
    try {
      await _runWithDeferredLoading(
        action: () => lingo.setLanguage(language),
        show: () =>
            _showFullScreenLoading(context.getText(AppKeys.switchingLanguage)),
        hide: _hideFullScreenLoading,
      );
      if (mounted) {
        setState(() => _isChangingLanguage = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isChangingLanguage = false);
      }
    }
  }

  Future<T> _runWithDeferredLoading<T>({
    required Future<T> Function() action,
    required VoidCallback show,
    required VoidCallback hide,
  }) async {
    var completed = false;
    var visible = false;
    Future<void>.delayed(settingsLoadingDelay, () {
      if (completed || !mounted) {
        return;
      }
      visible = true;
      show();
    });

    try {
      return await action();
    } finally {
      completed = true;
      if (visible && mounted) {
        hide();
      }
    }
  }

  void _showFullScreenLoading(String message) {
    showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: Colors.white,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) {
        return PopScope(canPop: false, child: LoadingScreen(message: message));
      },
    );
  }

  void _hideFullScreenLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _returnToSettings() {
    HapticFeedback.selectionClick();
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget._isPushedPage) {
      Navigator.of(context).maybePop();
      return;
    }
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    setState(() {
      _view = SettingPageView.settings;
      _isForwardTransition = false;
      _isEditing = false;
      _isPickingAccountAvatar = false;
      _draftAvatarPath = null;
    });
    _loadProfiles();
  }

  void _openAddProfile() {
    if (!_canCreateProfile) {
      return;
    }
    if (!widget._isPushedPage) {
      _pushView(SettingPageView.profile, openAddProfileOnStart: true);
      return;
    }
    if (_view == SettingPageView.profile) {
      _pushView(SettingPageView.addProfile);
      return;
    }

    HapticFeedback.selectionClick();
    _resetCreateProfileForm();
    setState(() {
      _view = SettingPageView.addProfile;
      _isForwardTransition = true;
      _profileCreateError = null;
    });
    FocusScope.of(context).unfocus();
    if (!_hasProfileOptions) {
      _loadProfileOptions();
    }
  }

  void _openUpdateProfile(StudentProfile profile) {
    if (!widget._isPushedPage || _view == SettingPageView.profile) {
      _pushView(SettingPageView.addProfile, editingProfile: profile);
      return;
    }

    HapticFeedback.selectionClick();
    _resetCreateProfileForm();
    _profileNameController.text = profile.name?.trim() ?? '';
    _editingProfile = profile;
    _selectedProfileAvatarKey = profile.avatarKey?.trim();
    if (_profileRole(profile) == 'PARENT') {
      _applyParentContactFields();
    } else {
      _selectOptionsForProfile(profile);
      _applyProfileIdFields(profile);
    }
    setState(() {
      _view = SettingPageView.addProfile;
      _isForwardTransition = true;
      _profileCreateError = null;
    });
    FocusScope.of(context).unfocus();
    if (_profileRole(profile) != 'PARENT' && !_hasProfileOptions) {
      _loadProfileOptions(profileToSelect: profile);
    }
  }

  void _returnToProfileList() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget._isPushedPage) {
      HapticFeedback.selectionClick();
      Navigator.of(context).maybePop();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _view = SettingPageView.profile;
      _isForwardTransition = false;
      _profileCreateError = null;
    });
  }

  void _cancelAddProfile() {
    _resetCreateProfileForm();
    _returnToProfileList();
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

  Future<void> _saveEditing() async {
    final user = _effectiveUser;
    final userId = user?.id;
    if (userId == null || userId <= 0) {
      context.showErrorDialog(context.readText(AppKeys.missingAccount));
      return;
    }

    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      context.showErrorDialog(context.readText(AppKeys.accountNameRequired));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSavingAccount = true);

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
        _updatedUser = updatedUser;
        _localAvatarPath = _draftAvatarPath;
        _draftAvatarPath = null;
        _isEditing = false;
        _isPickingAccountAvatar = false;
        _isSavingAccount = false;
      });
      FocusScope.of(context).unfocus();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSavingAccount = false);
      context.showErrorDialog(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSavingAccount = false);
      context.showErrorDialog(context.readText(AppKeys.accountUpdateFailed));
    }
  }

  void _cancelEditing() {
    HapticFeedback.selectionClick();
    _restoreEditSnapshot();
    setState(() {
      _draftAvatarPath = null;
      _isEditing = false;
      _isSavingAccount = false;
      _isPickingAccountAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _restoreEditSnapshot() {
    _usernameController.text = _snapshotUsername ?? _usernameController.text;
    _phoneController.text = _snapshotPhone ?? _phoneController.text;
    _emailController.text = _snapshotEmail ?? _emailController.text;
    _localAvatarPath = _snapshotAvatarPath;
  }

  Future<void> _pickAccountAvatar() async {
    if (!_isEditing || _isPickingAccountAvatar) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _isPickingAccountAvatar = true);

    try {
      final path = await _avatarPicker.pickAvatarPath();
      if (!mounted) {
        return;
      }

      setState(() {
        if (path != null) {
          _draftAvatarPath = path;
        }
        _isPickingAccountAvatar = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isPickingAccountAvatar = false);
      context.showErrorDialog(context.readText(AppKeys.imagePickFailed));
    }
  }

  Future<void> _loadProfiles() async {
    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoadingProfiles = false;
        _profileLoadError = context.readText(AppKeys.noAccountForProfile);
        _profiles = const <StudentProfile>[];
      });
      return;
    }

    setState(() {
      _isLoadingProfiles = true;
      _profileLoadError = null;
    });

    await _profileManagementCubit.loadProfiles(userId);
    if (!mounted) {
      return;
    }
    final profileState = _profileManagementCubit.state;
    if (profileState.errorMessage != null) {
      setState(() {
        _profileLoadError = profileState.errorMessage;
        _isLoadingProfiles = false;
      });
    } else {
      setState(() {
        _profiles = profileState.profiles;
        _localActiveProfileId = profileState.activeProfileId;
        _isLoadingProfiles = false;
      });
    }
  }

  bool get _hasProfileOptions {
    return _gradeOptions.isNotEmpty &&
        _programOptions.isNotEmpty &&
        _semesterOptions.isNotEmpty &&
        _schoolOptions.isNotEmpty;
  }

  void _preloadProfileOptions() {
    if (_hasProfileOptions || _isLoadingProfileOptions) {
      return;
    }

    final userId = widget.user?.id;
    if (userId != null &&
        userId > 0 &&
        _applyCachedProfileOptions(userId: userId)) {
      return;
    }

    _loadProfileOptions();
  }

  Future<void> _loadProfileOptions({StudentProfile? profileToSelect}) async {
    if (_isLoadingProfileOptions) {
      return;
    }

    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingProfileOptions = false;
        _profileOptionsError = context.readText(
          AppKeys.profileOptionsMissingAccount,
        );
      });
      return;
    }

    if (_applyCachedProfileOptions(
      userId: userId,
      profileToSelect: profileToSelect,
    )) {
      return;
    }

    setState(() {
      _isLoadingProfileOptions = true;
      _profileOptionsError = null;
    });

    try {
      final results = await Future.wait<Object>([
        _schoolService.listSchools(),
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _profileService.listSemesters(userId: userId),
      ]);
      final schools = results[0] as List<SchoolModel>;
      final grades = results[1] as List<GradeModel>;
      final programs = results[2] as List<ProgramModel>;
      final semesters = results[3] as List<SemesterModel>;
      ProfileOptionsCache.instance.save(
        userId: userId,
        schools: schools,
        grades: grades,
        programs: programs,
        semesters: semesters,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _applyProfileOptions(
          schools: schools,
          grades: grades,
          programs: programs,
          semesters: semesters,
          profileToSelect: profileToSelect,
        );
        _isLoadingProfileOptions = false;
      });
    } on GradeException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileOptionsError = error.message;
        _isLoadingProfileOptions = false;
      });
    } on SchoolException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileOptionsError = error.message.isNotEmpty
            ? error.message
            : context.readText(AppKeys.schoolOptionsLoadFailed);
        _isLoadingProfileOptions = false;
      });
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileOptionsError = error.message;
        _isLoadingProfileOptions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileOptionsError = context.readText(
          AppKeys.profileOptionsLoadFailed,
        );
        _isLoadingProfileOptions = false;
      });
    }
  }

  bool _applyCachedProfileOptions({
    required int userId,
    StudentProfile? profileToSelect,
  }) {
    final cached = ProfileOptionsCache.instance.readFresh(userId: userId);
    if (cached == null) {
      return false;
    }
    if (mounted) {
      setState(() {
        _applyProfileOptions(
          schools: cached.schools,
          grades: cached.grades,
          programs: cached.programs,
          semesters: cached.semesters,
          profileToSelect: profileToSelect,
        );
        _isLoadingProfileOptions = false;
        _profileOptionsError = null;
      });
    }
    return true;
  }

  void _applyProfileOptions({
    required List<SchoolModel> schools,
    required List<GradeModel> grades,
    required List<ProgramModel> programs,
    required List<SemesterModel> semesters,
    StudentProfile? profileToSelect,
  }) {
    _schoolOptions = schools;
    _gradeOptions = grades;
    _programOptions = programs;
    _semesterOptions = semesters;
    final profile = profileToSelect ?? _editingProfile;
    if (profile != null) {
      _selectOptionsForProfile(profile);
    } else {
      _selectedSchool = null;
      _selectedGrade = null;
      _selectedProgram = null;
      _selectedSemester ??= semesters.isEmpty ? null : semesters.first;
    }
  }

  void _selectProfileAvatar(String avatarKey) {
    HapticFeedback.selectionClick();
    setState(() => _selectedProfileAvatarKey = avatarKey);
  }

  void _clearProfileAvatar() {
    HapticFeedback.selectionClick();
    setState(() => _selectedProfileAvatarKey = null);
  }

  Future<void> _saveProfileForm() async {
    final userId = widget.user?.id;
    final name = _profileNameController.text.trim();
    final school = _selectedSchool;
    final grade = _selectedGrade;
    final program = _selectedProgram;
    final semester = _selectedSemester;
    final editingProfile = _editingProfile;
    final formRole = _profileFormRole(editingProfile);
    final isTeacherProfile = formRole == 'TEACHER';
    final isParentProfile = formRole == 'PARENT';
    final normalizedIdType = _normalizedProfileIdType(
      _selectedProfileIdType,
      formRole,
    );
    final profileIdValue = _profileIdController.text.trim();
    final shouldSubmitTeacherId =
        isTeacherProfile &&
        normalizedIdType != null &&
        profileIdValue.isNotEmpty;
    final isCreatingFirstProfile = editingProfile == null && _profiles.isEmpty;
    final isUpdatingProfile = editingProfile != null;
    StudentProfile? createdActiveProfile;

    if (userId == null || userId <= 0) {
      setState(
        () => _profileCreateError = context.readText(AppKeys.missingAccount),
      );
      return;
    }
    if ((editingProfile == null || isParentProfile) && name.isEmpty) {
      setState(
        () =>
            _profileCreateError = context.readText(AppKeys.missingProfileName),
      );
      return;
    }
    if (!isParentProfile && school?.schoolId == null) {
      setState(
        () => _profileCreateError = context.readText(
          AppKeys.missingProfileSelections,
        ),
      );
      return;
    }
    if (!isTeacherProfile &&
        !isParentProfile &&
        editingProfile == null &&
        (grade?.gradeId == null ||
            program?.programId == null ||
            semester?.semesterId == null)) {
      setState(
        () => _profileCreateError = context.readText(
          AppKeys.missingProfileSelections,
        ),
      );
      return;
    }
    if (isTeacherProfile &&
        normalizedIdType == null &&
        profileIdValue.isNotEmpty) {
      setState(
        () => _profileCreateError = context.readText(
          AppKeys.missingProfileSelections,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSavingProfile = true;
      _isUpdatingProfile = isUpdatingProfile;
      _profileCreateError = null;
    });

    try {
      if (editingProfile == null) {
        final createdProfile = await _profileService.createProfile(
          userId: userId,
          schoolId: school!.schoolId!,
          name: name,
          gradeId: isTeacherProfile ? null : grade!.gradeId!,
          programId: isTeacherProfile ? null : program!.programId!,
          semesterId: isTeacherProfile ? null : semester!.semesterId!,
          isDefault: _profiles.isEmpty,
          role: formRole,
          avatarKey: _selectedProfileAvatarKey,
          idType: isTeacherProfile ? normalizedIdType : settingsIdTypeMoet,
          studentId: isTeacherProfile ? null : profileIdValue,
          teacherId: shouldSubmitTeacherId ? profileIdValue : null,
        );
        if (formRole == 'STUDENT' || isCreatingFirstProfile) {
          final profileId = ActiveProfileSession.profileStableId(
            createdProfile,
          );
          if (profileId != null) {
            createdActiveProfile = createdProfile;
          }
        }
      } else {
        final profileId = editingProfile.profileId;
        if (profileId == null) {
          throw ProfileException(context.readText(AppKeys.missingProfileId));
        }

        if (isParentProfile) {
          await _profileService.updateProfile(
            profileId: profileId,
            name: name,
            avatarKey: _selectedProfileAvatarKey,
          );
        } else {
          await _profileService.updateProfile(
            profileId: profileId,
            schoolId: school!.schoolId!,
            name: settingsEmptyToNull(name),
            gradeId: isTeacherProfile ? null : grade?.gradeId,
            programId: isTeacherProfile ? null : program?.programId,
            semesterId: isTeacherProfile ? null : semester?.semesterId,
            isDefault: editingProfile.isDefault,
            role: formRole,
            dob: _dateOnly(editingProfile.dob),
            avatarKey: _selectedProfileAvatarKey,
            idType: isTeacherProfile ? normalizedIdType : settingsIdTypeMoet,
            studentId: isTeacherProfile ? null : profileIdValue,
            teacherId: shouldSubmitTeacherId ? profileIdValue : null,
          );
        }
      }
      if (!mounted) {
        return;
      }

      if (isUpdatingProfile) {
        await (widget.onRefreshProfiles?.call() ?? Future<void>.value());
        if (!mounted) {
          return;
        }
      }

      if (createdActiveProfile != null) {
        await _runWithDeferredLoading(
          action: () => widget.onActivateProfile(createdActiveProfile!),
          show: () => setState(() => _isSwitchingProfile = true),
          hide: () => setState(() => _isSwitchingProfile = false),
        );
        if (!mounted) {
          return;
        }
        setState(() {
          _localActiveProfileId = ActiveProfileSession.profileStableId(
            createdActiveProfile,
          );
        });
      }

      if (widget._isPushedPage && _view == SettingPageView.addProfile) {
        setState(() {
          _isSavingProfile = false;
          _isUpdatingProfile = false;
        });
        widget.onProfileSaved?.call();
        return;
      }

      _resetCreateProfileForm();
      setState(() {
        _isSavingProfile = false;
        _isUpdatingProfile = false;
        _view = SettingPageView.profile;
        _isForwardTransition = false;
      });
      await _loadProfiles();
      if (mounted && _isSwitchingProfile) {
        setState(() => _isSwitchingProfile = false);
      }
      widget.onProfileSaved?.call();
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileCreateError = error.message;
        _isSavingProfile = false;
        _isUpdatingProfile = false;
        _isSwitchingProfile = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileCreateError = editingProfile == null
            ? context.readText(AppKeys.profileCreateFailed)
            : context.readText(AppKeys.profileUpdateFailed);
        _isSavingProfile = false;
        _isUpdatingProfile = false;
        _isSwitchingProfile = false;
      });
    }
  }

  Future<void> _confirmDeleteProfile(StudentProfile profile) async {
    final profileId = profile.profileId;
    if (profileId == null) {
      context.showErrorDialog(context.readText(AppKeys.missingProfileId));
      return;
    }

    HapticFeedback.selectionClick();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.readText(AppKeys.deleteProfileTitle)),
          content: Text(
            context.readText(AppKeys.deleteProfileMessage),
            style: GoogleFonts.andika(
              color: const Color(0xFF1B1B1B),
              fontSize: FontSize.normal,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.readText(AppKeys.cancel)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.readText(AppKeys.delete)),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteProfile(profileId);
  }

  Future<void> _selectActiveProfile(StudentProfile selectedProfile) async {
    final userId = widget.user?.id;
    final profileId = ActiveProfileSession.profileStableId(selectedProfile);
    if (_isSettingDefaultProfile ||
        userId == null ||
        userId <= 0 ||
        profileId == null ||
        profileId == _activeProfileId) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _isSettingDefaultProfile = true;
    });

    try {
      await _runWithDeferredLoading(
        action: () => widget.onActivateProfile(selectedProfile),
        show: () => setState(() => _isSwitchingProfile = true),
        hide: () => setState(() => _isSwitchingProfile = false),
      );
      if (!mounted) {
        return;
      }
      setState(() => _localActiveProfileId = profileId);
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(context.readText(AppKeys.profileUpdateFailed));
    } finally {
      if (mounted) {
        setState(() {
          _isSettingDefaultProfile = false;
          _isSwitchingProfile = false;
        });
      }
    }
  }

  Future<void> _deleteProfile(int profileId) async {
    setState(() => _isDeletingProfile = true);
    final deletedActiveProfile = profileId == _activeProfileId;

    try {
      await _profileService.forceDeleteProfile(profileId: profileId);
      if (!mounted) {
        return;
      }

      if (deletedActiveProfile) {
        final userId = widget.user?.id;
        if (userId != null && userId > 0) {
          await _activeProfileSession.clearActiveProfileId(userId);
        }
      }
      await _loadProfiles();
      await widget.onRefreshProfiles?.call();
      if (deletedActiveProfile && mounted) {
        NumiApp.restart(context);
      }
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      context.showErrorDialog(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      context.showErrorDialog(context.readText(AppKeys.profileDeleteFailed));
    } finally {
      if (mounted) {
        setState(() => _isDeletingProfile = false);
      }
    }
  }

  void _resetCreateProfileForm() {
    _profileNameController.clear();
    _profilePhoneController.clear();
    _profileEmailController.clear();
    _profileIdController.clear();
    _selectedProfileAvatarKey = null;
    _editingProfile = null;
    _profileCreateError = null;
    _selectedProfileIdType = null;
    _selectedSchool = null;
    _selectedGrade = null;
    _selectedProgram = null;
    _selectedSemester = _semesterOptions.isEmpty
        ? null
        : _semesterOptions.first;
  }

  void _selectOptionsForProfile(StudentProfile profile) {
    _selectedSchool = _firstWhereOrNull(
      _schoolOptions,
      (school) => school.schoolId == profile.schoolId,
    );
    _selectedGrade = _firstWhereOrNull(
      _gradeOptions,
      (grade) => grade.gradeId == profile.gradeId,
    );
    _selectedProgram = _firstWhereOrNull(
      _programOptions,
      (program) => program.programId == profile.programId,
    );
    _selectedSemester = _firstWhereOrNull(
      _semesterOptions,
      (semester) => semester.semesterId == profile.semesterId,
    );
    _selectedProfileAvatarKey = profile.avatarKey?.trim();
    _applyProfileIdFields(profile);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final topInset = widget._isPushedPage
        ? 0.0
        : MediaQuery.paddingOf(context).top;
    final headerTitle = _titleForView(context, _view, _editingProfile);
    final canGoBack = widget._isPushedPage || _view != SettingPageView.settings;
    final backgroundColor = context.themeColors.pageBackground;
    final lingo = LingoScope.of(context);

    return PopScope(
      canPop: !_isSwitchingProfile && !_isUpdatingProfile,
      child: Stack(
        children: [
          ColoredBox(
            color: backgroundColor,
            child: DefaultTextStyle.merge(
              style: GoogleFonts.andika(letterSpacing: 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: widget.bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SettingHeader(
                      title: headerTitle,
                      canGoBack: canGoBack,
                      onBack: _view == SettingPageView.addProfile
                          ? _returnToProfileList
                          : _returnToSettings,
                      backgroundColor: backgroundColor,
                      scale: scale,
                      topInset: topInset,
                    ),
                    SizedBox(height: _topGapForView(_view) * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  for (final child in previousChildren) child,
                                  ?currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isIncoming =
                                  child.key == ValueKey(_viewKey(_view));
                              final forward = _isForwardTransition;
                              final beginX = isIncoming
                                  ? (forward ? 0.10 : -0.10)
                                  : (forward ? -0.08 : 0.08);
                              final offset = Tween<Offset>(
                                begin: Offset(beginX, 0),
                                end: Offset.zero,
                              ).animate(animation);

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offset,
                                  child: child,
                                ),
                              );
                            },
                            child: switch (_view) {
                              SettingPageView.settings => SettingsMenuPanel(
                                key: ValueKey(
                                  _viewKey(SettingPageView.settings),
                                ),
                                activeProfile: widget.activeProfile,
                                fallbackAvatarUrl: _effectiveUser?.avatarUrl,
                                fallbackAvatarPath: _localAvatarPath,
                                username: settingsFallbackUsername(
                                  _effectiveUser,
                                ),
                                scale: scale,
                                currentLanguage: lingo.language,
                                hasPasscode: _hasPasscode,
                                isLoadingPasscode: _isLoadingPasscode,
                                animateActions:
                                    widget.isActive &&
                                    !_hasPlayedSettingsMenuEntrance,
                                onActionsAnimationEnd:
                                    _markSettingsMenuEntrancePlayed,
                                onAccountTap: () =>
                                    _pushView(SettingPageView.account),
                                onProfileTap: () =>
                                    _pushView(SettingPageView.profile),
                                onPasscodeTap: _openPasscodeSettings,
                                onLanguageChanged: _changeLanguage,
                                onLogoutTap: widget.onLogout,
                              ),
                              SettingPageView.account => AccountDetailsPanel(
                                key: ValueKey(
                                  _viewKey(SettingPageView.account),
                                ),
                                avatarUrl: _effectiveUser?.avatarUrl,
                                avatarPath: _isEditing
                                    ? _draftAvatarPath
                                    : _localAvatarPath,
                                usernameController: _usernameController,
                                phoneController: _phoneController,
                                emailController: _emailController,
                                isEditing: _isEditing,
                                isSaving: _isSavingAccount,
                                isPickingAvatar: _isPickingAccountAvatar,
                                onEdit: _startEditing,
                                onSave: _saveEditing,
                                onCancel: _cancelEditing,
                                onAvatarTap: _pickAccountAvatar,
                                scale: scale,
                              ),
                              SettingPageView.profile =>
                                ProfilePlaceholderPanel(
                                  key: ValueKey(
                                    _viewKey(SettingPageView.profile),
                                  ),
                                  profiles: _profiles,
                                  activeProfile: widget.activeProfile,
                                  user: _effectiveUser,
                                  activeProfileId: _activeProfileId,
                                  isLoading:
                                      _isLoadingProfiles ||
                                      _isDeletingProfile ||
                                      _isSettingDefaultProfile,
                                  errorMessage: _profileLoadError,
                                  onRetry: _loadProfiles,
                                  onAdd: _openAddProfile,
                                  onSelect: _selectActiveProfile,
                                  onEdit: _openUpdateProfile,
                                  onDelete: _confirmDeleteProfile,
                                  scale: scale,
                                  canAddProfile: _canCreateProfile,
                                ),
                              SettingPageView.addProfile => AddProfilePanel(
                                key: ValueKey(
                                  _viewKey(SettingPageView.addProfile),
                                ),
                                nameController: _profileNameController,
                                phoneController: _profilePhoneController,
                                emailController: _profileEmailController,
                                idController: _profileIdController,
                                role: _profileFormRole(_editingProfile),
                                avatarKey: _selectedProfileAvatarKey,
                                avatarUrl: _editingProfile?.avatarUrl,
                                schools: _schoolOptions,
                                grades: _gradeOptions,
                                programs: _programOptions,
                                selectedSchool: _selectedSchool,
                                selectedGrade: _selectedGrade,
                                selectedProgram: _selectedProgram,
                                selectedIdType: _selectedProfileIdType,
                                isLoadingOptions: _isLoadingProfileOptions,
                                isSaving: _isSavingProfile,
                                canSave: _canSaveProfileForm,
                                errorMessage:
                                    _profileOptionsError ?? _profileCreateError,
                                canRetryOptions: _profileOptionsError != null,
                                onAvatarChanged: _selectProfileAvatar,
                                onClearAvatar: _clearProfileAvatar,
                                onSchoolChanged: (school) {
                                  setState(() => _selectedSchool = school);
                                },
                                onGradeChanged: (grade) {
                                  setState(() => _selectedGrade = grade);
                                },
                                onProgramChanged: (program) {
                                  setState(() => _selectedProgram = program);
                                },
                                onIdTypeChanged: (idType) {
                                  setState(() {
                                    _selectedProfileIdType = idType;
                                    _profileIdController.clear();
                                  });
                                },
                                onRetryOptions: _loadProfileOptions,
                                onCancel: _cancelAddProfile,
                                onSave: _saveProfileForm,
                                scale: scale,
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSwitchingProfile || _isUpdatingProfile)
            Positioned.fill(
              child: LoadingScreen(
                message: context.getText(
                  _isUpdatingProfile
                      ? AppKeys.updatingProfile
                      : AppKeys.switchingProfile,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _applyParentContactFields() {
    final user = _effectiveUser;
    _profilePhoneController.text = settingsDisplayPhone(
      user?.phone,
      fallback: '',
    );
    _profileEmailController.text = user?.email?.trim() ?? '';
  }

  void _markSettingsMenuEntrancePlayed() {
    if (!mounted || _hasPlayedSettingsMenuEntrance) {
      return;
    }
    setState(() => _hasPlayedSettingsMenuEntrance = true);
  }

  static String _viewKey(SettingPageView view) {
    return switch (view) {
      SettingPageView.settings => 'settings-menu',
      SettingPageView.account => 'account-details',
      SettingPageView.profile => 'profile-placeholder',
      SettingPageView.addProfile => 'add-profile',
    };
  }

  static String _titleForView(
    BuildContext context,
    SettingPageView view,
    StudentProfile? editingProfile,
  ) {
    return switch (view) {
      SettingPageView.settings => context.getText(AppKeys.settingsTitle),
      SettingPageView.account => context.getText(AppKeys.accountTitle),
      SettingPageView.profile => context.getText(AppKeys.profileTitle),
      SettingPageView.addProfile => context.getText(AppKeys.profileTitle),
    };
  }

  static double _topGapForView(SettingPageView view) {
    return switch (view) {
      SettingPageView.settings => 30,
      SettingPageView.account => 36,
      SettingPageView.profile => 30,
      SettingPageView.addProfile => 30,
    };
  }

  static T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }

  static String? _dateOnly(String? value) {
    final date = value?.trim();
    if (date == null || date.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(date);
    if (parsed == null) {
      return date.length >= 10 ? date.substring(0, 10) : date;
    }
    return parsed.toIso8601String().substring(0, 10);
  }

  static String _profileRole(StudentProfile profile) {
    final role = profile.role?.trim().toUpperCase();
    return switch (role) {
      'TEACHER' || 'PARENT' || 'STUDENT' => role!,
      _ => 'STUDENT',
    };
  }

  String _profileFormRole(StudentProfile? editingProfile) {
    if (editingProfile != null) {
      return _profileRole(editingProfile);
    }

    final userRole = widget.user?.role?.trim().toUpperCase();
    return userRole == 'TEACHER' ? 'TEACHER' : 'STUDENT';
  }

  bool get _canCreateProfile {
    final userRole = _effectiveUser?.role?.trim().toUpperCase();
    if (userRole == 'STUDENT' || userRole?.endsWith('_STUDENT') == true) {
      return false;
    }
    if (userRole == 'PARENT' ||
        userRole == 'TEACHER' ||
        userRole?.endsWith('_PARENT') == true ||
        userRole?.endsWith('_TEACHER') == true) {
      return true;
    }

    return _profiles.any(
      (profile) => ProfileRole.fromProfile(profile) != ProfileRole.student,
    );
  }

  bool get _canSaveProfileForm {
    if (_isSavingProfile || _isLoadingProfileOptions) {
      return false;
    }

    final name = _profileNameController.text.trim();
    if (name.isEmpty) {
      return false;
    }

    final formRole = _profileFormRole(_editingProfile);
    if (formRole == 'PARENT') {
      return true;
    }

    if (_selectedSchool?.schoolId == null) {
      return false;
    }

    if (formRole == 'TEACHER') {
      return true;
    }

    return _selectedProgram?.programId != null &&
        _selectedGrade?.gradeId != null;
  }

  void _applyProfileIdFields(StudentProfile profile) {
    final role = _profileRole(profile);
    final idType = _normalizedProfileIdType(profile.idType, role);
    _selectedProfileIdType = idType;
    _profileIdController.text = role == 'TEACHER'
        ? profile.teacherId?.trim() ?? ''
        : profile.studentId?.trim() ?? '';
  }

  static String? _normalizedProfileIdType(String? value, String role) {
    final normalized = value?.trim().toUpperCase();
    if (role != 'TEACHER' && (normalized == null || normalized.isEmpty)) {
      return settingsIdTypeMoet;
    }
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final allowedOptions = role == 'TEACHER'
        ? teacherIdTypeOptions
        : studentIdTypeOptions;
    final isAllowed = allowedOptions.any(
      (option) => option.value == normalized,
    );
    return isAllowed ? normalized : null;
  }

  int? get _activeProfileId {
    return _localActiveProfileId;
  }
}
