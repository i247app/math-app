import 'package:numi/features/profile/models/profile_id_type_option.dart';
import 'package:numi/features/settings/application/settings_constants.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
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
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/profile_management_cubit.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/profile_exception.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/shared/widgets/loading_screen.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/data/profile_options_cache.dart';
import 'package:numi/features/settings/application/settings_passcode_controller.dart';
import 'package:numi/features/settings/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/helpers/settings_profile_helpers.dart';
import 'package:numi/features/settings/models/setting_screen_args.dart';
import 'package:numi/features/settings/navigation/settings_passcode_flow.dart';
import 'package:numi/features/settings/presentation/setting_account_screen.dart';
import 'package:numi/features/profile/widgets/profile_form_panel.dart';
import 'package:numi/features/profile/widgets/profile_list_panel.dart';
import 'package:numi/features/settings/widgets/setting_header.dart';
import 'package:numi/features/settings/widgets/setting_safe_screen.dart';
import 'package:numi/features/settings/widgets/settings_menu_panel.dart';

part 'setting_profile_management.dart';
part 'setting_profile_form.dart';

enum SettingPageView { settings, account, profile, addProfile }

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
    this.scale = 1,
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
    this.scale = 1,
    SettingPageView initialView = SettingPageView.settings,
    StudentProfile? initialEditingProfile,
    bool isPushedPage = false,
    bool openAddProfileOnStart = false,
    this.isActive = true,
  }) : openAddProfileRequestId = 0,
       _initialView = initialView,
       _initialEditingProfile = initialEditingProfile,
       _isPushedPage = isPushedPage,
       _openAddProfileOnStart = openAddProfileOnStart,
       assert(initialView != SettingPageView.account);

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

class _SettingTabState extends State<SettingTab>
    with _SettingProfileManagementMixin, _SettingProfileFormMixin {
  final SettingsPasscodeController _passcodeController =
      SettingsPasscodeController();
  final SettingsPasscodeFlow _passcodeFlow = const SettingsPasscodeFlow();

  @override
  late final SettingPageView _view;
  bool _isChangingLanguage = false;
  bool _hasPlayedSettingsMenuEntrance = false;
  bool _isPasscodeStatusLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _view = widget._initialView;
    _initializeProfileManagementState();
    _initializeProfileFormState();
    _passcodeController.addListener(_onPasscodeChanged);
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
    _updateProfileManagementState(oldWidget);
    _updateProfileFormState(oldWidget);

    if (oldWidget.user?.id != widget.user?.id) {
      _schedulePasscodeStatusLoad();
    }
  }

  @override
  void dispose() {
    _passcodeController
      ..removeListener(_onPasscodeChanged)
      ..dispose();
    _disposeProfileFormState();
    _disposeProfileManagementState();
    super.dispose();
  }

  int? get _effectiveUserId {
    final userId = widget.user?.id;
    return userId != null && userId > 0 ? userId : null;
  }

  void _onPasscodeChanged() {
    if (mounted) {
      setState(() {});
    }
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
      _passcodeController.load(_effectiveUserId);
    });
  }

  @override
  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  }) async {
    if (view != SettingPageView.account) {
      HapticFeedback.selectionClick();
    }
    FocusScope.of(context).unfocus();

    final screen = _settingScreenForView(
      view,
      editingProfile,
      openAddProfileOnStart: openAddProfileOnStart,
    );
    final route =
        view == SettingPageView.account || view == SettingPageView.profile
        ? CupertinoPageRoute<bool>(builder: (_) => screen)
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

  @override
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
    }
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

    return GuardedExitScope<bool>(
      controller: _profileExitController,
      shouldConfirm:
          _view == SettingPageView.addProfile && _isProfileDraftDirty,
      isExitBlocked:
          _isSavingProfile || _isSwitchingProfile || _isUpdatingProfile,
      confirmExit: showUnsavedChangesExitDialog,
      child: Stack(
        children: [
          ColoredBox(
            color: backgroundColor,
            child: DefaultTextStyle.merge(
              style: GoogleFonts.andika(letterSpacing: 0),
              child: SingleChildScrollView(
                physics:
                    widget._isPushedPage && _view == SettingPageView.profile
                    ? const ClampingScrollPhysics()
                    : const BouncingScrollPhysics(),
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
                          ? _requestProfileFormExit
                          : _returnToSettings,
                      backgroundColor: backgroundColor,
                      topInset: topInset,
                    ),
                    SizedBox(height: _topGapForView(_view) * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                      child: switch (_view) {
                        SettingPageView.settings => SettingsMenuPanel(
                          activeProfile: widget.activeProfile,
                          fallbackAvatarUrl: widget.user?.avatarUrl,
                          fallbackAvatarPath: null,
                          username: settingsFallbackUsername(widget.user),
                          currentLanguage: lingo.language,
                          hasPasscode: _passcodeController.hasPasscode,
                          isLoadingPasscode: _passcodeController.isLoading,
                          animateActions:
                              widget.isActive &&
                              !_hasPlayedSettingsMenuEntrance,
                          onActionsAnimationEnd:
                              _markSettingsMenuEntrancePlayed,
                          onAccountTap: () =>
                              _pushView(SettingPageView.account),
                          onProfileTap: () =>
                              _pushView(SettingPageView.profile),
                          onPasscodeTap: () => _passcodeFlow.open(
                            context: context,
                            userId: _effectiveUserId,
                            controller: _passcodeController,
                          ),
                          onLanguageChanged: _changeLanguage,
                          onLogoutTap: widget.onLogout,
                        ),
                        SettingPageView.account => const SizedBox.shrink(),
                        SettingPageView.profile => ProfilePlaceholderPanel(
                          profiles: _profiles,
                          activeProfile: widget.activeProfile,
                          user: widget.user,
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
                          canAddProfile: _canCreateProfile,
                        ),
                        SettingPageView.addProfile => AddProfilePanel(
                          nameController: _profileNameController,
                          phoneController: _profilePhoneController,
                          emailController: _profileEmailController,
                          idController: _profileIdController,
                          role: settingsProfileFormRole(
                            user: widget.user,
                            editingProfile: _editingProfile,
                          ),
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
                        ),
                      },
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

  void _markSettingsMenuEntrancePlayed() {
    if (!mounted || _hasPlayedSettingsMenuEntrance) {
      return;
    }
    setState(() => _hasPlayedSettingsMenuEntrance = true);
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
}
