import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/numi_app.dart';
import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/network/school_models.dart';
import '../../../../core/network/program_models.dart';
import '../../../../core/network/semester_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/active_profile_session.dart';
import '../../data/avatar_picker.dart';
import '../../data/grade_api.dart';
import '../../data/otp_auth_api.dart';
import '../../data/passcode_service.dart';
import '../../data/profile_api.dart';
import '../../data/school_api.dart';
import '../../domain/profile_avatar.dart';
import '../screens/passcode_screen.dart';
import '../widgets/profile_avatar_image.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/lingo_scope.dart';

part '../screens/setting_account_screen.dart';
part '../screens/setting_profile_form_screen.dart';
part '../screens/setting_profile_list_screen.dart';
part 'widgets/setting_header.dart';
part 'widgets/settings_menu_panel.dart';
part 'widgets/account_details_panel.dart';
part 'widgets/profile_form_panel.dart';
part 'widgets/profile_list_panel.dart';

const _navy = Color(0xFF339395);
const _teal = Color(0xFF339395);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _orange = Color(0xFFDE5E31);
const _idTypeMoet = 'MOET';
const _idTypePublicId = 'PUBLIC_ID';

class _ProfileIdTypeOption {
  const _ProfileIdTypeOption(this.value, this.label);

  final String value;
  final String label;
}

const _studentIdTypeOptions = <_ProfileIdTypeOption>[
  _ProfileIdTypeOption(_idTypeMoet, AppKeys.idTypeMoetLabel),
];

const _teacherIdTypeOptions = <_ProfileIdTypeOption>[
  _ProfileIdTypeOption(_idTypeMoet, AppKeys.idTypeTeacherMoetLabel),
  _ProfileIdTypeOption(_idTypePublicId, AppKeys.idTypePublicIdLabel),
];

enum SettingPageView { settings, account, profile, addProfile }

class SettingTab extends StatefulWidget {
  const SettingTab({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    this.onProfileSaved,
    this.openAddProfileRequestId = 0,
    required this.bottomPadding,
    required this.scale,
  })  : _initialView = SettingPageView.settings,
        _initialEditingProfile = null,
        _isPushedPage = false,
        _popAfterProfileSave = false;

  const SettingTab.page({
    super.key,
    required this.user,
    required this.profiles,
    required this.activeProfile,
    required this.profileLoadError,
    required this.onLogout,
    this.onProfileSaved,
    required this.bottomPadding,
    required this.scale,
    SettingPageView initialView = SettingPageView.settings,
    StudentProfile? initialEditingProfile,
    bool isPushedPage = false,
    bool popAfterProfileSave = false,
  })  : openAddProfileRequestId = 0,
        _initialView = initialView,
        _initialEditingProfile = initialEditingProfile,
        _isPushedPage = isPushedPage,
        _popAfterProfileSave = popAfterProfileSave;

  final LoginUser? user;
  final List<StudentProfile> profiles;
  final StudentProfile? activeProfile;
  final String? profileLoadError;
  final VoidCallback onLogout;
  final VoidCallback? onProfileSaved;
  final int openAddProfileRequestId;
  final double bottomPadding;
  final double scale;
  final SettingPageView _initialView;
  final StudentProfile? _initialEditingProfile;
  final bool _isPushedPage;
  final bool _popAfterProfileSave;

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final OtpAuthService _authService = OtpAuthApi();
  final PasscodeService _passcodeService = const SecurePasscodeService();
  final ProfileService _profileService = ProfileApi();
  final GradeService _gradeService = GradeApi();
  final SchoolService _schoolService = SchoolApi();
  final ActiveProfileSession _activeProfileSession =
      const ActiveProfileSession();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();
  final TextEditingController _profileIdController = TextEditingController();

  late SettingPageView _view;
  bool _isForwardTransition = true;
  bool _isEditing = false;
  bool _isSavingAccount = false;
  bool _isPickingAccountAvatar = false;
  bool _isLoadingProfiles = false;
  bool _isLoadingProfileOptions = false;
  bool _isSavingProfile = false;
  bool _isDeletingProfile = false;
  bool _isSettingDefaultProfile = false;
  bool _isLoadingPasscode = false;
  bool _hasPasscode = false;
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

  @override
  void initState() {
    super.initState();
    _view = widget._initialView;
    _applyUser(widget.user);
    _profiles = widget.profiles;
    _profileLoadError = widget.profileLoadError;
    final initialEditingProfile = widget._initialEditingProfile;
    if (initialEditingProfile != null) {
      _editingProfile = initialEditingProfile;
      _profileNameController.text = initialEditingProfile.name?.trim() ?? '';
      _selectedProfileAvatarKey = initialEditingProfile.avatarKey?.trim();
      if (_profileRole(initialEditingProfile) != 'PARENT') {
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
      });
    } else if (_view == SettingPageView.addProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final isEditingParent = initialEditingProfile != null &&
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPasscodeStatus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SettingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    if (oldWidget.profileLoadError != widget.profileLoadError) {
      _profileLoadError = widget.profileLoadError;
    }

    if (oldWidget.user?.id != widget.user?.id) {
      _loadPasscodeStatus();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _profileNameController.dispose();
    _profileIdController.dispose();
    super.dispose();
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = _fallbackUsername(user);
    _phoneController.text = _displayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  LoginUser? get _effectiveUser => _updatedUser ?? widget.user;

  int? get _effectiveUserId {
    final userId = _effectiveUser?.id;
    return userId != null && userId > 0 ? userId : null;
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

    final action = await showModalBottomSheet<_PasscodeSettingsAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        return _PasscodeSettingsSheet(
          scale: widget.scale,
          onChange: () =>
              Navigator.of(sheetContext).pop(_PasscodeSettingsAction.change),
          onRemove: () =>
              Navigator.of(sheetContext).pop(_PasscodeSettingsAction.remove),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    switch (action) {
      case _PasscodeSettingsAction.change:
        await _changePasscode(userId);
      case _PasscodeSettingsAction.remove:
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
    _showSettingsSnack(AppKeys.passcodeSet);
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
    _showSettingsSnack(AppKeys.passcodeChanged);
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
      _showSettingsSnack(AppKeys.passcodeRemoved);
    } catch (_) {
      _showSettingsSnack(AppKeys.passcodeRemoveFailed);
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

  void _showSettingsSnack(String messageKey) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.getText(messageKey))),
    );
  }

  Future<void> _pushView(
    SettingPageView view, {
    StudentProfile? editingProfile,
  }) async {
    HapticFeedback.selectionClick();
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    _isEditing = false;
    _isPickingAccountAvatar = false;
    _draftAvatarPath = null;
    FocusScope.of(context).unfocus();

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _settingScreenForView(view, editingProfile),
      ),
    );

    if (!mounted) {
      return;
    }
    _loadProfiles();
  }

  Widget _settingScreenForView(
    SettingPageView view,
    StudentProfile? editingProfile,
  ) {
    final args = _SettingScreenArgs(
      user: widget.user,
      profiles: _profiles,
      activeProfile: widget.activeProfile,
      profileLoadError: _profileLoadError,
      onLogout: widget.onLogout,
      onProfileSaved: widget.onProfileSaved,
      scale: widget.scale,
    );

    return switch (view) {
      SettingPageView.account => _SettingAccountScreen(args: args),
      SettingPageView.profile => _SettingProfileListScreen(args: args),
      SettingPageView.addProfile => _SettingProfileFormScreen(
          args: args,
          editingProfile: editingProfile,
        ),
      SettingPageView.settings => _SettingProfileListScreen(args: args),
    };
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    final lingo = LingoScope.read(context);
    if (lingo.language == language) {
      return;
    }
    await lingo.setLanguage(language);
    if (mounted) {
      NumiApp.restart(context);
    }
  }

  void _returnToSettings() {
    HapticFeedback.selectionClick();
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
    FocusScope.of(context).unfocus();
    _loadProfiles();
  }

  void _openAddProfile() {
    if (!widget._isPushedPage || _view == SettingPageView.profile) {
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
    if (_profileRole(profile) != 'PARENT') {
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
    FocusScope.of(context).unfocus();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.missingAccount))),
      );
      return;
    }

    final name = _usernameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.accountNameRequired))),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSavingAccount = true);

    try {
      final avatarPath =
          _draftAvatarPath != _snapshotAvatarPath ? _draftAvatarPath : null;
      final updatedUser = await _authService.updateUser(
        userId: userId,
        name: name,
        phone: _normalizedPhone(_phoneController.text),
        email: _emptyToNull(_emailController.text),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.accountUpdated))),
      );
    } on OtpAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSavingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSavingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.accountUpdateFailed))),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.imagePickFailed))),
      );
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

    try {
      final profiles = await _profileService.listProfiles(userId: userId);
      if (!mounted) {
        return;
      }

      setState(() {
        _profiles = profiles;
        _isLoadingProfiles = false;
      });
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileLoadError = error.message;
        _isLoadingProfiles = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _profileLoadError = context.readText(AppKeys.profileLoadFailed);
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

    _loadProfileOptions();
  }

  Future<void> _loadProfileOptions({StudentProfile? profileToSelect}) async {
    if (_isLoadingProfileOptions) {
      return;
    }

    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoadingProfileOptions = false;
        _profileOptionsError =
            context.readText(AppKeys.profileOptionsMissingAccount);
      });
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
      if (!mounted) {
        return;
      }

      setState(() {
        _schoolOptions = schools;
        _gradeOptions = grades;
        _programOptions = programs;
        _semesterOptions = semesters;
        final profile = profileToSelect ?? _editingProfile;
        if (profile != null) {
          _selectOptionsForProfile(profile);
        } else {
          _selectedSchool ??= schools.isEmpty ? null : schools.first;
          _selectedGrade ??= grades.isEmpty ? null : grades.first;
          _selectedProgram ??= programs.isEmpty ? null : programs.first;
          _selectedSemester ??= semesters.isEmpty ? null : semesters.first;
        }
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
        _profileOptionsError =
            context.readText(AppKeys.profileOptionsLoadFailed);
        _isLoadingProfileOptions = false;
      });
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
    final shouldSubmitTeacherId = isTeacherProfile &&
        normalizedIdType != null &&
        profileIdValue.isNotEmpty;
    final isCreatingFirstProfile = editingProfile == null && _profiles.isEmpty;

    if (userId == null || userId <= 0) {
      setState(
          () => _profileCreateError = context.readText(AppKeys.missingAccount));
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
        () => _profileCreateError =
            context.readText(AppKeys.missingProfileSelections),
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
        () => _profileCreateError =
            context.readText(AppKeys.missingProfileSelections),
      );
      return;
    }
    if (isTeacherProfile &&
        ((normalizedIdType == null && profileIdValue.isNotEmpty) ||
            (normalizedIdType != null && profileIdValue.isEmpty))) {
      setState(
        () => _profileCreateError =
            context.readText(AppKeys.missingProfileSelections),
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
          idType: isTeacherProfile ? normalizedIdType : _idTypeMoet,
          studentId: isTeacherProfile ? null : profileIdValue,
          teacherId: shouldSubmitTeacherId ? profileIdValue : null,
        );
        if (formRole == 'STUDENT' || isCreatingFirstProfile) {
          final profileId =
              ActiveProfileSession.profileStableId(createdProfile);
          if (profileId != null) {
            await _activeProfileSession.writeActiveProfileId(
              userId: userId,
              profileId: profileId,
            );
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
            name: _emptyToNull(name),
            gradeId: isTeacherProfile ? null : grade?.gradeId,
            programId: isTeacherProfile ? null : program?.programId,
            semesterId: isTeacherProfile ? null : semester?.semesterId,
            isDefault: editingProfile.isDefault,
            role: formRole,
            dob: _dateOnly(editingProfile.dob),
            avatarKey: _selectedProfileAvatarKey,
            idType: isTeacherProfile ? normalizedIdType : _idTypeMoet,
            studentId: isTeacherProfile ? null : profileIdValue,
            teacherId: shouldSubmitTeacherId ? profileIdValue : null,
          );
        }
      }
      if (!mounted) {
        return;
      }

      _resetCreateProfileForm();
      setState(() {
        _isSavingProfile = false;
        _view = SettingPageView.profile;
        _isForwardTransition = false;
      });
      await _loadProfiles();
      widget.onProfileSaved?.call();
      if (widget._popAfterProfileSave && mounted) {
        Navigator.of(context).maybePop();
        return;
      }
      if (isCreatingFirstProfile && mounted) {
        NumiApp.restart(context);
      }
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

  Future<void> _confirmDeleteProfile(StudentProfile profile) async {
    final profileId = profile.profileId;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.missingProfileId))),
      );
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
              fontSize: 16,
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
    setState(() => _isSettingDefaultProfile = true);

    try {
      await _activeProfileSession.writeActiveProfileId(
        userId: userId,
        profileId: profileId,
      );
      if (!mounted) {
        return;
      }
      NumiApp.restart(context);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.profileUpdateFailed))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSettingDefaultProfile = false);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.profileDeleted))),
      );
      if (deletedActiveProfile) {
        final userId = widget.user?.id;
        if (userId != null && userId > 0) {
          await _activeProfileSession.clearActiveProfileId(userId);
        }
      }
      await _loadProfiles();
      if (deletedActiveProfile && mounted) {
        NumiApp.restart(context);
      }
    } on ProfileException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.profileDeleteFailed))),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingProfile = false);
      }
    }
  }

  void _resetCreateProfileForm() {
    _profileNameController.clear();
    _profileIdController.clear();
    _selectedProfileAvatarKey = null;
    _editingProfile = null;
    _profileCreateError = null;
    _selectedProfileIdType = null;
    _selectedSchool = _schoolOptions.isEmpty ? null : _schoolOptions.first;
    _selectedGrade = _gradeOptions.isEmpty ? null : _gradeOptions.first;
    _selectedProgram = _programOptions.isEmpty ? null : _programOptions.first;
    _selectedSemester =
        _semesterOptions.isEmpty ? null : _semesterOptions.first;
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
    final topInset =
        widget._isPushedPage ? 0.0 : MediaQuery.paddingOf(context).top;
    final headerTitle = _titleForView(context, _view, _editingProfile);
    final canGoBack = widget._isPushedPage || _view != SettingPageView.settings;
    const backgroundColor = Colors.white;
    final lingo = LingoScope.of(context);

    return ColoredBox(
      color: backgroundColor,
      child: DefaultTextStyle.merge(
        style: GoogleFonts.andika(letterSpacing: 0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: widget.bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingHeader(
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
                            if (currentChild != null) currentChild,
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
                          child:
                              SlideTransition(position: offset, child: child),
                        );
                      },
                      child: switch (_view) {
                        SettingPageView.settings => _SettingsMenuPanel(
                            key: ValueKey(_viewKey(SettingPageView.settings)),
                            activeProfile: widget.activeProfile,
                            fallbackAvatarUrl: _effectiveUser?.avatarUrl,
                            fallbackAvatarPath: _localAvatarPath,
                            username: _fallbackUsername(_effectiveUser),
                            scale: scale,
                            currentLanguage: lingo.language,
                            hasPasscode: _hasPasscode,
                            isLoadingPasscode: _isLoadingPasscode,
                            onAccountTap: () =>
                                _pushView(SettingPageView.account),
                            onProfileTap: () =>
                                _pushView(SettingPageView.profile),
                            onPasscodeTap: _openPasscodeSettings,
                            onLanguageChanged: _changeLanguage,
                            onLogoutTap: widget.onLogout,
                          ),
                        SettingPageView.account => _AccountDetailsPanel(
                            key: ValueKey(_viewKey(SettingPageView.account)),
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
                        SettingPageView.profile => _ProfilePlaceholderPanel(
                            key: ValueKey(_viewKey(SettingPageView.profile)),
                            profiles: _profiles,
                            activeProfile: widget.activeProfile,
                            user: _effectiveUser,
                            activeProfileId: _activeProfileId,
                            isLoading: _isLoadingProfiles ||
                                _isDeletingProfile ||
                                _isSettingDefaultProfile,
                            errorMessage: _profileLoadError,
                            onRetry: _loadProfiles,
                            onAdd: _openAddProfile,
                            onSelect: _selectActiveProfile,
                            onEdit: _openUpdateProfile,
                            onDelete: _confirmDeleteProfile,
                            scale: scale,
                          ),
                        SettingPageView.addProfile => _AddProfilePanel(
                            key: ValueKey(_viewKey(SettingPageView.addProfile)),
                            nameController: _profileNameController,
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
    );
  }

  static String _fallbackUsername(LoginUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'alex_parent';
  }

  static String _displayPhone(String? value) {
    final phone = value?.trim();
    if (phone == null || phone.isEmpty) {
      return '090 123 4567';
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('84') && digits.length > 2) {
      return _formatLocalPhone('0${digits.substring(2)}');
    }

    return _formatLocalPhone(digits);
  }

  static String? _normalizedPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }

  static String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _formatLocalPhone(String digits) {
    if (digits.length == 10 && digits.startsWith('0')) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} '
          '${digits.substring(6)}';
    }

    return digits;
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
      return _idTypeMoet;
    }
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final allowedOptions =
        role == 'TEACHER' ? _teacherIdTypeOptions : _studentIdTypeOptions;
    final isAllowed =
        allowedOptions.any((option) => option.value == normalized);
    return isAllowed ? normalized : null;
  }

  int? get _activeProfileId {
    return ActiveProfileSession.profileStableId(widget.activeProfile);
  }
}
