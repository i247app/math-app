import 'package:numi/features/profile/presentation/models/profile_id_type_option.dart';
import 'package:numi/features/settings/presentation/models/settings_constants.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi/app/numi_app.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/data/adapters/active_profile_session.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/semester.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:numi/features/profile/application/controllers/profile_management_cubit.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/errors/grade_exception.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/data/errors/profile_exception.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/features/profile/application/errors/school_exception.dart';
import 'package:numi/shared/widgets/loading_screen.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';
import 'package:numi/core/localization/app_language.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/features/profile/data/cache/profile_options_cache.dart';
import 'package:numi/features/settings/application/controllers/settings_passcode_controller.dart';
import 'package:numi/features/session/application/services/passcode_service.dart';
import 'package:numi/features/settings/presentation/helpers/settings_account_helpers.dart';
import 'package:numi/features/settings/presentation/helpers/settings_profile_helpers.dart';
import 'package:numi/features/settings/presentation/models/setting_screen_args.dart';
import 'package:numi/features/settings/presentation/navigation/settings_passcode_flow.dart';
import 'package:numi/features/settings/presentation/screens/setting_account_screen.dart';
import 'package:numi/features/profile/presentation/widgets/profile_form_panel.dart';
import 'package:numi/features/profile/presentation/widgets/profile_list_panel.dart';
import 'package:numi/features/settings/presentation/widgets/setting_header.dart';
import 'package:numi/features/settings/presentation/widgets/setting_safe_screen.dart';
import 'package:numi/features/settings/presentation/widgets/settings_menu_panel.dart';

part 'setting_profile_management.dart';
part 'setting_profile_form.dart';

part 'setting/navigation_actions.dart';

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
  late final SettingsPasscodeController _passcodeController;
  final SettingsPasscodeFlow _passcodeFlow = const SettingsPasscodeFlow();

  @override
  late final SettingPageView _view;
  bool _isChangingLanguage = false;
  bool _hasPlayedSettingsMenuEntrance = false;
  bool _isPasscodeStatusLoadScheduled = false;

  @override
  void initState() {
    super.initState();
    _passcodeController = SettingsPasscodeController(
      service: context.read<PasscodeService>(),
    );
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
      isExitBlocked: _isSavingProfile,
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
                          switchingProfileId: _switchingProfileId,
                          isLoading: _isLoadingProfiles || _isDeletingProfile,
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

  @override
  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  }) {
    return _performPushView(
      view,
      editingProfile: editingProfile,
      openAddProfileOnStart: openAddProfileOnStart,
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
