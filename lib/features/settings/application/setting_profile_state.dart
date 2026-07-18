part of 'setting_tab.dart';

mixin _SettingProfileStateMixin on State<SettingTab> {
  final ProfileService _profileService = ProfileApi();
  final GradeService _gradeService = GradeApi();
  final SchoolService _schoolService = SchoolApi();
  final ActiveProfileSession _activeProfileSession =
      const ActiveProfileSession();
  late final ProfileManagementCubit _profileManagementCubit;

  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profilePhoneController = TextEditingController();
  final TextEditingController _profileEmailController = TextEditingController();
  final TextEditingController _profileIdController = TextEditingController();

  bool _isLoadingProfiles = false;
  bool _isLoadingProfileOptions = false;
  bool _isSavingProfile = false;
  bool _isUpdatingProfile = false;
  bool _isDeletingProfile = false;
  bool _isSettingDefaultProfile = false;
  bool _isSwitchingProfile = false;
  String? _profileLoadError;
  String? _profileOptionsError;
  String? _profileCreateError;
  String? _selectedProfileAvatarKey;
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

  SettingPageView get _view;

  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
    bool openAddProfileOnStart = false,
  });

  Future<T> _runWithDeferredLoading<T>({
    required Future<T> Function() action,
    required VoidCallback show,
    required VoidCallback hide,
  });

  void _initializeProfileState() {
    _profileManagementCubit = ProfileManagementCubit(
      profileService: _profileService,
      gradeService: _gradeService,
      schoolService: _schoolService,
      activeProfileSession: _activeProfileSession,
    );
    _profileNameController.addListener(_onProfileNameChanged);
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
  }

  void _updateProfileState(SettingTab oldWidget) {
    if (oldWidget.user != widget.user) {
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
  }

  void _disposeProfileState() {
    _profileManagementCubit.close();
    _profileNameController.removeListener(_onProfileNameChanged);
    _profileNameController.dispose();
    _profilePhoneController.dispose();
    _profileEmailController.dispose();
    _profileIdController.dispose();
  }

  void _onProfileNameChanged() {
    if (!mounted || _view != SettingPageView.addProfile) {
      return;
    }
    setState(() {});
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

  void _returnToProfileList() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget._isPushedPage) {
      HapticFeedback.selectionClick();
      Navigator.of(context).maybePop();
      return;
    }

    HapticFeedback.selectionClick();
  }

  void _cancelAddProfile() {
    _resetCreateProfileForm();
    _returnToProfileList();
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

      setState(() {
        _isSavingProfile = false;
        _isUpdatingProfile = false;
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

  void _applyParentContactFields() {
    final user = widget.user;
    _profilePhoneController.text = settingsDisplayPhone(
      user?.phone,
      fallback: '',
    );
    _profileEmailController.text = user?.email?.trim() ?? '';
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
    final userRole = widget.user?.role?.trim().toUpperCase();
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
      return profileIdTypeMoet;
    }
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final allowedOptions = role == 'TEACHER'
        ? teacherProfileIdTypeOptions
        : studentProfileIdTypeOptions;
    final isAllowed = allowedOptions.any(
      (option) => option.value == normalized,
    );
    return isAllowed ? normalized : null;
  }

  int? get _activeProfileId {
    return _localActiveProfileId;
  }
}
