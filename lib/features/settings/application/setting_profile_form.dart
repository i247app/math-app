part of 'setting_tab.dart';

mixin _SettingProfileFormMixin
    on State<SettingTab>, _SettingProfileManagementMixin {
  final GuardedExitController<bool> _profileExitController =
      GuardedExitController<bool>();
  ProfileService get _formProfileService => context.read<ProfileService>();
  GradeService get _gradeService => context.read<GradeService>();
  SchoolService get _schoolService => context.read<SchoolService>();

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
      final results = await Future.wait<Object>([
        _schoolService.listSchools(),
        _gradeService.listGrades(userId: userId),
        _formProfileService.listPrograms(userId: userId),
        _formProfileService.listSemesters(userId: userId),
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
    final formRole = settingsProfileFormRole(
      user: widget.user,
      editingProfile: editingProfile,
    );
    final isTeacherProfile = formRole == 'TEACHER';
    final isParentProfile = formRole == 'PARENT';
    final normalizedIdType = settingsNormalizedProfileIdType(
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
      _profileCreateError = null;
    });

    try {
      if (editingProfile == null) {
        final createdProfile = await _formProfileService.createProfile(
          userId: userId,
          schoolId: school!.schoolId!,
          name: name,
          gradeId: isTeacherProfile ? null : grade!.gradeId!,
          programId: isTeacherProfile ? null : program!.programId!,
          semesterId: isTeacherProfile ? null : semester!.semesterId!,
          isDefault: _profiles.isEmpty,
          role: formRole,
          avatarKey: _selectedProfileAvatarKey,
          idType: isTeacherProfile ? normalizedIdType : profileIdTypeMoet,
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
          await _formProfileService.updateProfile(
            profileId: profileId,
            name: name,
            avatarKey: _selectedProfileAvatarKey,
          );
        } else {
          await _formProfileService.updateProfile(
            profileId: profileId,
            schoolId: school!.schoolId!,
            name: settingsEmptyToNull(name),
            gradeId: isTeacherProfile ? null : grade?.gradeId,
            programId: isTeacherProfile ? null : program?.programId,
            semesterId: isTeacherProfile ? null : semester?.semesterId,
            isDefault: editingProfile.isDefault,
            role: formRole,
            dob: settingsProfileDateOnly(editingProfile.dob),
            avatarKey: _selectedProfileAvatarKey,
            idType: isTeacherProfile ? normalizedIdType : profileIdTypeMoet,
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
        await widget.onActivateProfile(createdActiveProfile);
        if (!mounted) {
          return;
        }
        setState(() {
          _localActiveProfileId = ActiveProfileSession.profileStableId(
            createdActiveProfile,
          );
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
        _profileCreateError = editingProfile == null
            ? context.readText(AppKeys.profileCreateFailed)
            : context.readText(AppKeys.profileUpdateFailed);
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
    if (_isSavingProfile || _isLoadingProfileOptions) {
      return false;
    }

    final name = _profileNameController.text.trim();
    if (name.isEmpty) {
      return false;
    }

    final formRole = settingsProfileFormRole(
      user: widget.user,
      editingProfile: _editingProfile,
    );
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
    final role = settingsProfileRole(profile);
    final idType = settingsNormalizedProfileIdType(profile.idType, role);
    _selectedProfileIdType = idType;
    _profileIdController.text = role == 'TEACHER'
        ? profile.teacherId?.trim() ?? ''
        : profile.studentId?.trim() ?? '';
  }
}
