part of 'setting_tab.dart';

mixin _SettingProfileFormMixin
    on State<SettingTab>, _SettingProfileManagementMixin {
  final GuardedExitController<bool> _profileExitController =
      GuardedExitController<bool>();
  SettingsProfileFormService get _profileFormService =>
      SettingsProfileFormService(
        profileService: context.read<ProfileService>(),
        gradeService: context.read<GradeService>(),
        schoolService: context.read<SchoolService>(),
      );

  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profilePhoneController = TextEditingController();
  final TextEditingController _profileEmailController = TextEditingController();
  final TextEditingController _profileIdController = TextEditingController();

  bool _isLoadingProfileOptions = false;
  bool _isSavingProfile = false;
  bool _suppressProfileDraftTracking = false;
  String? _profileDraftBaseline;
  String? _profileOptionsError;
  String? _profileCreateError;
  String? _selectedProfileAvatarKey;
  StudentProfile? _editingProfile;
  List<SchoolModel> _schoolOptions = const <SchoolModel>[];
  List<GradeModel> _gradeOptions = const <GradeModel>[];
  List<ProgramModel> _programOptions = const <ProgramModel>[];
  List<SemesterModel> _semesterOptions = const <SemesterModel>[];
  SchoolModel? _selectedSchool;
  GradeModel? _selectedGrade;
  ProgramModel? _selectedProgram;
  SemesterModel? _selectedSemester;
  String? _selectedProfileIdType;

  SettingsProfileDraft get _profileDraft => SettingsProfileDraft(
    user: widget.user,
    name: _profileNameController.text,
    hasProfiles: _profiles.isNotEmpty,
    editingProfile: _editingProfile,
    schoolId: _selectedSchool?.schoolId,
    gradeId: _selectedGrade?.gradeId,
    programId: _selectedProgram?.programId,
    semesterId: _selectedSemester?.semesterId,
    avatarKey: _selectedProfileAvatarKey,
    idType: _selectedProfileIdType,
    identifier: _profileIdController.text,
  );

  void _initializeProfileFormState() {
    _suppressProfileDraftTracking = true;
    _profileNameController.addListener(_onProfileDraftFieldChanged);
    _profilePhoneController.addListener(_onProfileDraftFieldChanged);
    _profileEmailController.addListener(_onProfileDraftFieldChanged);
    _profileIdController.addListener(_onProfileDraftFieldChanged);
    final initialEditingProfile = widget._initialEditingProfile;
    if (initialEditingProfile != null) {
      _editingProfile = initialEditingProfile;
      _profileNameController.text = initialEditingProfile.name?.trim() ?? '';
      _selectedProfileAvatarKey = initialEditingProfile.avatarKey?.trim();
      if (settingsProfileRole(initialEditingProfile) == 'PARENT') {
        _applyParentContactFields();
      } else {
        _applyProfileIdFields(initialEditingProfile);
      }
    }
    _suppressProfileDraftTracking = false;
    _captureProfileDraftBaseline();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_view == SettingPageView.profile) {
        _preloadProfileOptions();
        return;
      }
      if (_view != SettingPageView.addProfile) {
        return;
      }
      final isEditingParent =
          initialEditingProfile != null &&
          settingsProfileRole(initialEditingProfile) == 'PARENT';
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

  void _updateProfileFormState(SettingTab oldWidget) {
    if (oldWidget.user == widget.user) {
      return;
    }
    _schoolOptions = const <SchoolModel>[];
    _gradeOptions = const <GradeModel>[];
    _programOptions = const <ProgramModel>[];
    _semesterOptions = const <SemesterModel>[];
    _selectedSchool = null;
    _selectedGrade = null;
    _selectedProgram = null;
    _selectedSemester = null;
    _profileOptionsError = null;
    if (_view == SettingPageView.profile) {
      _preloadProfileOptions();
    }
  }

  void _disposeProfileFormState() {
    _profileNameController
      ..removeListener(_onProfileDraftFieldChanged)
      ..dispose();
    _profilePhoneController
      ..removeListener(_onProfileDraftFieldChanged)
      ..dispose();
    _profileEmailController
      ..removeListener(_onProfileDraftFieldChanged)
      ..dispose();
    _profileIdController
      ..removeListener(_onProfileDraftFieldChanged)
      ..dispose();
  }

  void _onProfileDraftFieldChanged() {
    if (!mounted ||
        _view != SettingPageView.addProfile ||
        _suppressProfileDraftTracking) {
      return;
    }
    setState(() {});
  }

  bool get _isProfileDraftDirty {
    final baseline = _profileDraftBaseline;
    return baseline != null && _profileDraftFingerprint() != baseline;
  }

  String _profileDraftFingerprint() {
    return <Object?>[
      _profileNameController.text,
      _profilePhoneController.text,
      _profileEmailController.text,
      _profileIdController.text,
      _selectedProfileAvatarKey,
      _selectedSchool?.schoolId,
      _selectedGrade?.gradeId,
      _selectedProgram?.programId,
      _selectedProfileIdType,
    ].map((value) => value?.toString() ?? '').join('\u001f');
  }

  void _captureProfileDraftBaseline() {
    _profileDraftBaseline = _profileDraftFingerprint();
  }

  void _cancelAddProfile() {
    _requestProfileFormExit();
  }

  void _requestProfileFormExit() {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.selectionClick();
    _profileExitController.requestExit();
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
      final options = await _profileFormService.loadOptions(userId);
      if (!mounted) {
        return;
      }

      setState(() {
        _applyProfileOptions(options, profileToSelect: profileToSelect);
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
    final cached = _profileFormService.cachedOptions(userId);
    if (cached == null) {
      return false;
    }
    if (mounted) {
      setState(() {
        _applyProfileOptions(cached, profileToSelect: profileToSelect);
        _isLoadingProfileOptions = false;
        _profileOptionsError = null;
      });
    }
    return true;
  }

  void _applyProfileOptions(
    ProfileOptionsSnapshot options, {
    StudentProfile? profileToSelect,
  }) {
    _schoolOptions = options.schools;
    _gradeOptions = options.grades;
    _programOptions = options.programs;
    _semesterOptions = options.semesters;
    final profile = profileToSelect ?? _editingProfile;
    if (profile != null) {
      _selectOptionsForProfile(profile);
    } else {
      _selectedSchool = null;
      _selectedGrade = null;
      _selectedProgram = null;
      _selectedSemester ??= options.semesters.isEmpty
          ? null
          : options.semesters.first;
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
    final draft = _profileDraft;
    final errorKey = draft.validationErrorKey;
    if (errorKey != null) {
      setState(() => _profileCreateError = context.readText(errorKey));
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSavingProfile = true;
      _profileCreateError = null;
    });

    try {
      final result = await _profileFormService.save(draft);
      if (!mounted) {
        return;
      }

      if (result.requiresProfileRefresh) {
        await (widget.onRefreshProfiles?.call() ?? Future<void>.value());
        if (!mounted) {
          return;
        }
      }

      final createdActiveProfile = result.profileToActivate;
      if (createdActiveProfile != null) {
        await widget.onActivateProfile(createdActiveProfile);
        if (!mounted) {
          return;
        }
        setState(() {
          _localActiveProfileId = profileStableId(createdActiveProfile);
        });
      }

      setState(() {
        _isSavingProfile = false;
        _captureProfileDraftBaseline();
      });
      widget.onProfileSaved?.call();
      return;
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileCreateError = error.message;
        _isSavingProfile = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileCreateError = context.readText(
          draft.isUpdating
              ? AppKeys.profileUpdateFailed
              : AppKeys.profileCreateFailed,
        );
        _isSavingProfile = false;
      });
    }
  }

  void _resetCreateProfileForm() {
    _suppressProfileDraftTracking = true;
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
    _suppressProfileDraftTracking = false;
    _captureProfileDraftBaseline();
  }

  void _selectOptionsForProfile(StudentProfile profile) {
    final hadUnsavedChanges = _isProfileDraftDirty;
    _suppressProfileDraftTracking = true;
    _selectedSchool = settingsFirstWhereOrNull(
      _schoolOptions,
      (school) => school.schoolId == profile.schoolId,
    );
    _selectedGrade = settingsFirstWhereOrNull(
      _gradeOptions,
      (grade) => grade.gradeId == profile.gradeId,
    );
    _selectedProgram = settingsFirstWhereOrNull(
      _programOptions,
      (program) => program.programId == profile.programId,
    );
    _selectedSemester = settingsFirstWhereOrNull(
      _semesterOptions,
      (semester) => semester.semesterId == profile.semesterId,
    );
    _selectedProfileAvatarKey = profile.avatarKey?.trim();
    _applyProfileIdFields(profile);
    _suppressProfileDraftTracking = false;
    if (!hadUnsavedChanges) {
      _captureProfileDraftBaseline();
    }
  }

  void _applyParentContactFields() {
    _suppressProfileDraftTracking = true;
    final user = widget.user;
    _profilePhoneController.text = settingsDisplayPhone(
      user?.phone,
      fallback: '',
    );
    _profileEmailController.text = user?.email?.trim() ?? '';
    _suppressProfileDraftTracking = false;
  }

  bool get _canSaveProfileForm {
    return !_isSavingProfile &&
        !_isLoadingProfileOptions &&
        _profileDraft.canSave;
  }

  void _applyProfileIdFields(StudentProfile profile) {
    final role = settingsProfileRole(profile);
    final idType = settingsNormalizedProfileIdType(profile.idType, role);
    _selectedProfileIdType = idType;
    _profileIdController.text = role == 'TEACHER'
        ? profile.teacherId?.trim() ?? ''
        : profile.studentId?.trim() ?? '';
  }
}
