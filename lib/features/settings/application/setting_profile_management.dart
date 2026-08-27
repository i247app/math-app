part of 'setting_tab.dart';

mixin _SettingProfileManagementMixin on State<SettingTab> {
  ProfileService get _profileService => context.read<ProfileService>();
  final ActiveProfileSession _activeProfileSession =
      const ActiveProfileSession();
  late final ProfileManagementCubit _profileManagementCubit;

  bool _isLoadingProfiles = false;
  bool _isDeletingProfile = false;
  bool _isSettingDefaultProfile = false;
  int? _switchingProfileId;
  String? _profileLoadError;
  List<StudentProfile> _profiles = const <StudentProfile>[];
  int? _localActiveProfileId;

  SettingPageView get _view;

  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  });

  void _initializeProfileManagementState() {
    _profileManagementCubit = ProfileManagementCubit(
      profileService: _profileService,
      gradeService: context.read<GradeService>(),
      schoolService: context.read<SchoolService>(),
      activeProfileSession: _activeProfileSession,
    );
    _profiles = widget.profiles;
    _localActiveProfileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    _profileLoadError = widget.profileLoadError;

    if (_view == SettingPageView.profile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _loadProfiles();
        if (widget._openAddProfileOnStart) {
          _openAddProfile();
        }
      });
    }
  }

  void _updateProfileManagementState(SettingTab oldWidget) {
    if (oldWidget.user != widget.user) {
      _profiles = widget.profiles;
      _profileLoadError = widget.profileLoadError;
      if (_view == SettingPageView.profile) {
        _loadProfiles();
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
  }

  void _disposeProfileManagementState() {
    _profileManagementCubit.close();
  }

  void _openAddProfile() {
    if (!_canCreateProfile) {
      return;
    }
    if (!widget._isPushedPage) {
      _pushView(SettingPageView.profile, openAddProfileOnStart: true);
      return;
    }
    _pushView(SettingPageView.addProfile);
  }

  void _openUpdateProfile(StudentProfile profile) {
    _pushView(SettingPageView.addProfile, editingProfile: profile);
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
      _switchingProfileId = profileId;
    });

    try {
      await widget.onActivateProfile(selectedProfile);
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
          _switchingProfileId = null;
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

  bool get _canCreateProfile {
    return settingsCanCreateProfile(user: widget.user, profiles: _profiles);
  }

  int? get _activeProfileId {
    return _localActiveProfileId;
  }
}
