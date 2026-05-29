import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/localization_extension.dart';
import '../../../../core/localization/app_keys.dart';
import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/network/program_models.dart';
import '../../../../core/network/semester_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/avatar_picker.dart';
import '../../data/grade_api.dart';
import '../../data/otp_auth_api.dart';
import '../../data/profile_api.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/lingo_scope.dart';

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

enum _AccountView { settings, account, profile, addProfile }

class SettingTab extends StatefulWidget {
  const SettingTab({
    super.key,
    required this.user,
    required this.onLogout,
    this.onProfileSaved,
    this.openAddProfileRequestId = 0,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final VoidCallback onLogout;
  final VoidCallback? onProfileSaved;
  final int openAddProfileRequestId;
  final double bottomPadding;
  final double scale;

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final OtpAuthService _authService = OtpAuthApi();
  final ProfileService _profileService = ProfileApi();
  final GradeService _gradeService = GradeApi();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  _AccountView _view = _AccountView.settings;
  bool _isForwardTransition = true;
  bool _isEditing = false;
  bool _isSavingAccount = false;
  bool _isPickingAccountAvatar = false;
  bool _isLoadingProfiles = false;
  bool _isLoadingProfileOptions = false;
  bool _isPickingCreateAvatar = false;
  bool _isSavingProfile = false;
  bool _isDeletingProfile = false;
  bool _isSettingDefaultProfile = false;
  String? _profileLoadError;
  String? _profileOptionsError;
  String? _profileCreateError;
  String? _localAvatarPath;
  String? _draftAvatarPath;
  String? _createAvatarPath;
  String? _snapshotUsername;
  String? _snapshotPhone;
  String? _snapshotEmail;
  String? _snapshotAvatarPath;
  LoginUser? _updatedUser;
  StudentProfile? _editingProfile;
  List<StudentProfile> _profiles = const <StudentProfile>[];
  List<GradeModel> _gradeOptions = const <GradeModel>[];
  List<ProgramModel> _programOptions = const <ProgramModel>[];
  List<SemesterModel> _semesterOptions = const <SemesterModel>[];
  GradeModel? _selectedGrade;
  ProgramModel? _selectedProgram;
  SemesterModel? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _applyUser(widget.user);
    if (widget.openAddProfileRequestId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openAddProfile();
        }
      });
    }
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
      _profiles = const <StudentProfile>[];
      _gradeOptions = const <GradeModel>[];
      _programOptions = const <ProgramModel>[];
      _semesterOptions = const <SemesterModel>[];
      _selectedGrade = null;
      _selectedProgram = null;
      _selectedSemester = null;
      _profileLoadError = null;
      _profileOptionsError = null;
      if (_view == _AccountView.profile) {
        _loadProfiles();
        _preloadProfileOptions();
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _profileNameController.dispose();
    super.dispose();
  }

  void _applyUser(LoginUser? user) {
    _usernameController.text = _fallbackUsername(user);
    _phoneController.text = _displayPhone(user?.phone);
    _emailController.text = user?.email?.trim() ?? '';
  }

  LoginUser? get _effectiveUser => _updatedUser ?? widget.user;

  void _openView(_AccountView view) {
    HapticFeedback.selectionClick();
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    setState(() {
      _view = view;
      _isForwardTransition = true;
      _isEditing = false;
      _isPickingAccountAvatar = false;
      _draftAvatarPath = null;
    });
    FocusScope.of(context).unfocus();
    if (view == _AccountView.profile) {
      _loadProfiles();
      _preloadProfileOptions();
    }
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    HapticFeedback.selectionClick();
    await LingoScope.read(context).setLanguage(language);
    if (mounted) {
      setState(() {});
    }
  }

  void _returnToSettings() {
    HapticFeedback.selectionClick();
    if (_isEditing) {
      _restoreEditSnapshot();
    }
    setState(() {
      _view = _AccountView.settings;
      _isForwardTransition = false;
      _isEditing = false;
      _isPickingAccountAvatar = false;
      _draftAvatarPath = null;
    });
    FocusScope.of(context).unfocus();
    _loadProfiles();
  }

  void _openAddProfile() {
    HapticFeedback.selectionClick();
    _resetCreateProfileForm();
    setState(() {
      _view = _AccountView.addProfile;
      _isForwardTransition = true;
      _profileCreateError = null;
    });
    FocusScope.of(context).unfocus();
    if (!_hasProfileOptions) {
      _loadProfileOptions();
    }
  }

  void _openUpdateProfile(StudentProfile profile) {
    HapticFeedback.selectionClick();
    _resetCreateProfileForm();
    _profileNameController.text = profile.name?.trim() ?? '';
    _editingProfile = profile;
    _selectOptionsForProfile(profile);
    setState(() {
      _view = _AccountView.addProfile;
      _isForwardTransition = true;
      _profileCreateError = null;
    });
    FocusScope.of(context).unfocus();
    if (!_hasProfileOptions) {
      _loadProfileOptions(profileToSelect: profile);
    }
  }

  void _returnToProfileList() {
    HapticFeedback.selectionClick();
    setState(() {
      _view = _AccountView.profile;
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
    final userId = user?.id.trim();
    if (userId == null || userId.isEmpty) {
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
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
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
        _semesterOptions.isNotEmpty;
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

    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
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
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _profileService.listSemesters(userId: userId),
      ]);
      final grades = results[0] as List<GradeModel>;
      final programs = results[1] as List<ProgramModel>;
      final semesters = results[2] as List<SemesterModel>;
      if (!mounted) {
        return;
      }

      setState(() {
        _gradeOptions = grades;
        _programOptions = programs;
        _semesterOptions = semesters;
        final profile = profileToSelect ?? _editingProfile;
        if (profile != null) {
          _selectOptionsForProfile(profile);
        } else {
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

  Future<void> _pickCreateAvatar() async {
    if (_isPickingCreateAvatar) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _isPickingCreateAvatar = true);

    try {
      final path = await _avatarPicker.pickAvatarPath();
      if (!mounted) {
        return;
      }

      setState(() {
        if (path != null) {
          _createAvatarPath = path;
        }
        _isPickingCreateAvatar = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isPickingCreateAvatar = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.imagePickFailed))),
      );
    }
  }

  void _clearCreateAvatar() {
    HapticFeedback.selectionClick();
    setState(() => _createAvatarPath = null);
  }

  Future<void> _saveProfileForm() async {
    final userId = widget.user?.id.trim();
    final name = _profileNameController.text.trim();
    final grade = _selectedGrade;
    final program = _selectedProgram;
    final semester = _selectedSemester;
    final editingProfile = _editingProfile;

    if (userId == null || userId.isEmpty) {
      setState(
          () => _profileCreateError = context.readText(AppKeys.missingAccount));
      return;
    }
    if (editingProfile == null && name.isEmpty) {
      setState(
        () =>
            _profileCreateError = context.readText(AppKeys.missingProfileName),
      );
      return;
    }
    if (editingProfile == null &&
        (grade?.gradeId == null ||
            program?.programId == null ||
            semester?.semesterId == null)) {
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
        await _profileService.createProfile(
          userId: userId,
          name: name,
          gradeId: grade!.gradeId!,
          programId: program!.programId!,
          semesterId: semester!.semesterId!,
          isDefault: _profiles.isEmpty,
          role: 'STUDENT',
          avatarPath: _createAvatarPath,
        );
      } else {
        final profileId = editingProfile.profileId?.trim();
        if (profileId == null || profileId.isEmpty) {
          throw ProfileException(context.readText(AppKeys.missingProfileId));
        }

        await _profileService.updateProfile(
          profileId: profileId,
          name: _emptyToNull(name),
          gradeId: grade?.gradeId,
          programId: program?.programId,
          semesterId: semester?.semesterId,
          isDefault: editingProfile.isDefault,
          role: _profileRole(editingProfile),
          dob: _dateOnly(editingProfile.dob),
          avatarPath: _createAvatarPath,
        );
      }
      if (!mounted) {
        return;
      }

      _resetCreateProfileForm();
      setState(() {
        _isSavingProfile = false;
        _view = _AccountView.profile;
        _isForwardTransition = false;
      });
      await _loadProfiles();
      widget.onProfileSaved?.call();
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
    final profileId = profile.profileId?.trim();
    if (profileId == null || profileId.isEmpty) {
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

  Future<void> _selectDefaultProfile(StudentProfile selectedProfile) async {
    if (_isSettingDefaultProfile || selectedProfile.isDefault) {
      return;
    }

    final previousProfiles = _profiles.where(
      (profile) =>
          profile.isDefault && profile.profileId != selectedProfile.profileId,
    );

    HapticFeedback.selectionClick();
    setState(() => _isSettingDefaultProfile = true);

    try {
      for (final previousProfile in previousProfiles) {
        await _updateProfileDefault(previousProfile, isDefault: false);
      }
      await _updateProfileDefault(selectedProfile, isDefault: true);
      if (!mounted) {
        return;
      }
      await _loadProfiles();
      widget.onProfileSaved?.call();
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
        SnackBar(content: Text(context.readText(AppKeys.profileUpdateFailed))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSettingDefaultProfile = false);
      }
    }
  }

  Future<void> _updateProfileDefault(
    StudentProfile profile, {
    required bool isDefault,
  }) async {
    final profileId = profile.profileId?.trim();

    if (profileId == null || profileId.isEmpty) {
      throw ProfileException(context.readText(AppKeys.profileUpdateFailed));
    }

    await _profileService.updateProfile(
      profileId: profileId,
      isDefault: isDefault,
    );
  }

  Future<void> _deleteProfile(String profileId) async {
    setState(() => _isDeletingProfile = true);

    try {
      await _profileService.forceDeleteProfile(profileId: profileId);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.readText(AppKeys.profileDeleted))),
      );
      await _loadProfiles();
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
    _createAvatarPath = null;
    _editingProfile = null;
    _profileCreateError = null;
    _selectedGrade = _gradeOptions.isEmpty ? null : _gradeOptions.first;
    _selectedProgram = _programOptions.isEmpty ? null : _programOptions.first;
    _selectedSemester =
        _semesterOptions.isEmpty ? null : _semesterOptions.first;
  }

  void _selectOptionsForProfile(StudentProfile profile) {
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
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final headerTitle = _titleForView(context, _view, _editingProfile);
    final canGoBack = _view != _AccountView.settings;
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
                onBack: _view == _AccountView.addProfile
                    ? _returnToProfileList
                    : _returnToSettings,
                backgroundColor: backgroundColor,
                scale: scale,
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
                        _AccountView.settings => _SettingsMenuPanel(
                            key: ValueKey(_viewKey(_AccountView.settings)),
                            avatarUrl: _effectiveUser?.avatarUrl,
                            avatarPath: _localAvatarPath,
                            username: _fallbackUsername(_effectiveUser),
                            scale: scale,
                            currentLanguage: lingo.language,
                            onAccountTap: () => _openView(_AccountView.account),
                            onProfileTap: () => _openView(_AccountView.profile),
                            onLanguageChanged: _changeLanguage,
                            onLogoutTap: widget.onLogout,
                          ),
                        _AccountView.account => _AccountDetailsPanel(
                            key: ValueKey(_viewKey(_AccountView.account)),
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
                        _AccountView.profile => _ProfilePlaceholderPanel(
                            key: ValueKey(_viewKey(_AccountView.profile)),
                            profiles: _profiles,
                            isLoading: _isLoadingProfiles ||
                                _isDeletingProfile ||
                                _isSettingDefaultProfile,
                            errorMessage: _profileLoadError,
                            onRetry: _loadProfiles,
                            onAdd: _openAddProfile,
                            onSelect: _selectDefaultProfile,
                            onEdit: _openUpdateProfile,
                            onDelete: _confirmDeleteProfile,
                            scale: scale,
                          ),
                        _AccountView.addProfile => _AddProfilePanel(
                            key: ValueKey(_viewKey(_AccountView.addProfile)),
                            nameController: _profileNameController,
                            avatarPath: _createAvatarPath,
                            avatarUrl: _editingProfile?.avatarUrl,
                            grades: _gradeOptions,
                            programs: _programOptions,
                            selectedGrade: _selectedGrade,
                            selectedProgram: _selectedProgram,
                            isLoadingOptions: _isLoadingProfileOptions,
                            isPickingAvatar: _isPickingCreateAvatar,
                            isSaving: _isSavingProfile,
                            errorMessage:
                                _profileOptionsError ?? _profileCreateError,
                            canRetryOptions: _profileOptionsError != null,
                            onPickAvatar: _pickCreateAvatar,
                            onClearAvatar: _clearCreateAvatar,
                            onGradeChanged: (grade) {
                              setState(() => _selectedGrade = grade);
                            },
                            onProgramChanged: (program) {
                              setState(() => _selectedProgram = program);
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

  static String _viewKey(_AccountView view) {
    return switch (view) {
      _AccountView.settings => 'settings-menu',
      _AccountView.account => 'account-details',
      _AccountView.profile => 'profile-placeholder',
      _AccountView.addProfile => 'add-profile',
    };
  }

  static String _titleForView(
    BuildContext context,
    _AccountView view,
    StudentProfile? editingProfile,
  ) {
    return switch (view) {
      _AccountView.settings => context.getText(AppKeys.settingsTitle),
      _AccountView.account => context.getText(AppKeys.accountTitle),
      _AccountView.profile => context.getText(AppKeys.profileTitle),
      _AccountView.addProfile => context.getText(AppKeys.profileTitle),
    };
  }

  static double _topGapForView(_AccountView view) {
    return switch (view) {
      _AccountView.settings => 30,
      _AccountView.account => 36,
      _AccountView.profile => 30,
      _AccountView.addProfile => 30,
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
}
