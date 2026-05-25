import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/grade_models.dart';
import '../../../../core/network/profile_models.dart';
import '../../../../core/network/program_models.dart';
import '../../../../core/network/semester_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/avatar_picker.dart';
import '../../data/grade_api.dart';
import '../../data/otp_auth_api.dart';
import '../../data/profile_api.dart';

const _teal = Color(0xFF006762);
const _muted = Color(0xFF515F54);
const _deepInk = Color(0xFF253228);
const _orange = Color(0xFFDE5E31);

enum _AccountView { settings, account, profile, addProfile }

class SettingTab extends StatefulWidget {
  const SettingTab({
    super.key,
    required this.user,
    required this.onLogout,
    required this.bottomPadding,
    required this.scale,
  });

  final LoginUser? user;
  final VoidCallback onLogout;
  final double bottomPadding;
  final double scale;

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  final AvatarPickerService _avatarPicker = const AvatarPickerService();
  final ProfileService _profileService = ProfileApi();
  final GradeService _gradeService = GradeApi();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _profileNameController = TextEditingController();

  _AccountView _view = _AccountView.settings;
  bool _isForwardTransition = true;
  bool _isEditing = false;
  bool _isPickingAccountAvatar = false;
  bool _isLoadingProfiles = false;
  bool _isLoadingProfileOptions = false;
  bool _isPickingCreateAvatar = false;
  bool _isSavingProfile = false;
  bool _isDeletingProfile = false;
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
  }

  @override
  void didUpdateWidget(covariant SettingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user && !_isEditing) {
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

  void _saveEditing() {
    HapticFeedback.mediumImpact();
    setState(() {
      _localAvatarPath = _draftAvatarPath;
      _draftAvatarPath = null;
      _isEditing = false;
      _isPickingAccountAvatar = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _cancelEditing() {
    HapticFeedback.selectionClick();
    _restoreEditSnapshot();
    setState(() {
      _draftAvatarPath = null;
      _isEditing = false;
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
        const SnackBar(content: Text('Không thể chọn ảnh lúc này.')),
      );
    }
  }

  Future<void> _loadProfiles() async {
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
      setState(() {
        _isLoadingProfiles = false;
        _profileLoadError = 'Chưa có thông tin tài khoản để tải hồ sơ.';
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
        _profileLoadError = 'Tải hồ sơ thất bại.';
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
        _profileOptionsError = 'Chưa có thông tin tài khoản để tải lựa chọn.';
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
        _profileOptionsError = 'Tải lựa chọn hồ sơ thất bại.';
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
        const SnackBar(content: Text('Không thể chọn ảnh lúc này.')),
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
      setState(() => _profileCreateError = 'Thiếu thông tin tài khoản.');
      return;
    }
    if (name.isEmpty) {
      setState(() => _profileCreateError = 'Vui lòng nhập họ tên.');
      return;
    }
    if (grade?.gradeId == null ||
        program?.programId == null ||
        semester?.semesterId == null) {
      setState(() => _profileCreateError = 'Vui lòng chọn đủ thông tin.');
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
          avatarPath: _createAvatarPath,
        );
      } else {
        final profileId = editingProfile.profileId?.trim();
        if (profileId == null || profileId.isEmpty) {
          throw const ProfileException('Hồ sơ này thiếu profile_id.');
        }

        await _profileService.updateProfile(
          profileId: profileId,
          name: name,
          gradeId: grade!.gradeId!,
          programId: program!.programId!,
          semesterId: semester!.semesterId!,
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
            ? 'Không thể tạo hồ sơ. Vui lòng thử lại.'
            : 'Không thể cập nhật hồ sơ. Vui lòng thử lại.';
        _isSavingProfile = false;
      });
    }
  }

  Future<void> _confirmDeleteProfile(StudentProfile profile) async {
    final profileId = profile.profileId?.trim();
    if (profileId == null || profileId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hồ sơ này thiếu profile_id.')),
      );
      return;
    }

    HapticFeedback.selectionClick();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa hồ sơ?'),
          content: const Text(
            'Bạn có chắc muốn delete profile này không?',
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Xóa'),
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

  Future<void> _deleteProfile(String profileId) async {
    setState(() => _isDeletingProfile = true);

    try {
      await _profileService.forceDeleteProfile(profileId: profileId);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa hồ sơ.')),
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
        const SnackBar(content: Text('Không thể xóa hồ sơ. Vui lòng thử lại.')),
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
    final backgroundColor =
        _view == _AccountView.settings ? Colors.transparent : Colors.white;

    return ColoredBox(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          24 * scale,
          26 * scale,
          24 * scale,
          widget.bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AccountTitleRow(
              title: _view == _AccountView.settings
                  ? 'Cài đặt'
                  : _view == _AccountView.account
                      ? 'Tài khoản'
                      : _view == _AccountView.profile
                          ? 'Hồ sơ'
                          : _editingProfile == null
                              ? 'Thêm Hồ Sơ'
                              : 'Cập Nhật Hồ Sơ',
              canGoBack: _view != _AccountView.settings,
              scale: scale,
              onBack: _view == _AccountView.addProfile
                  ? _returnToProfileList
                  : _returnToSettings,
            ),
            SizedBox(height: 24 * scale),
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
                final isIncoming = child.key == ValueKey(_viewKey(_view));
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
                  child: SlideTransition(position: offset, child: child),
                );
              },
              child: switch (_view) {
                _AccountView.settings => _SettingsMenuPanel(
                    key: ValueKey(_viewKey(_AccountView.settings)),
                    avatarUrl: widget.user?.avatarUrl,
                    avatarPath: _localAvatarPath,
                    username: _fallbackUsername(widget.user),
                    scale: scale,
                    onAccountTap: () => _openView(_AccountView.account),
                    onProfileTap: () => _openView(_AccountView.profile),
                    onLogoutTap: widget.onLogout,
                  ),
                _AccountView.account => _AccountDetailsPanel(
                    key: ValueKey(_viewKey(_AccountView.account)),
                    avatarUrl: widget.user?.avatarUrl,
                    avatarPath:
                        _isEditing ? _draftAvatarPath : _localAvatarPath,
                    usernameController: _usernameController,
                    phoneController: _phoneController,
                    emailController: _emailController,
                    isEditing: _isEditing,
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
                    isLoading: _isLoadingProfiles || _isDeletingProfile,
                    errorMessage: _profileLoadError,
                    onRetry: _loadProfiles,
                    onAdd: _openAddProfile,
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
                    semesters: _semesterOptions,
                    selectedGrade: _selectedGrade,
                    selectedProgram: _selectedProgram,
                    selectedSemester: _selectedSemester,
                    isLoadingOptions: _isLoadingProfileOptions,
                    isPickingAvatar: _isPickingCreateAvatar,
                    isSaving: _isSavingProfile,
                    errorMessage: _profileOptionsError ?? _profileCreateError,
                    canRetryOptions: _profileOptionsError != null,
                    onPickAvatar: _pickCreateAvatar,
                    onClearAvatar: _clearCreateAvatar,
                    onGradeChanged: (grade) {
                      setState(() => _selectedGrade = grade);
                    },
                    onProgramChanged: (program) {
                      setState(() => _selectedProgram = program);
                    },
                    onSemesterChanged: (semester) {
                      setState(() => _selectedSemester = semester);
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
}

class _AccountTitleRow extends StatelessWidget {
  const _AccountTitleRow({
    required this.title,
    required this.canGoBack,
    required this.scale,
    required this.onBack,
  });

  final String title;
  final bool canGoBack;
  final double scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (!canGoBack) {
      return Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _teal,
                fontFamily: 'Nunito',
                fontSize: 24 * scale,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: HapticFeedback.selectionClick,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.all(2 * scale),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: _teal,
                  size: 28 * scale,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 34 * scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _teal,
                size: 22 * scale,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _teal,
              fontFamily: 'Nunito',
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        SizedBox(
          width: 34 * scale,
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: HapticFeedback.selectionClick,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: EdgeInsets.all(2 * scale),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: _teal,
                    size: 28 * scale,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountEditButton extends StatelessWidget {
  const _AccountEditButton({
    required this.enabled,
    required this.scale,
    required this.onTap,
  });

  final bool enabled;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Material(
        color: const Color(0xFFF7FBFD),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10 * scale),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Container(
            width: 42 * scale,
            height: 42 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: const Color(0xFFE4A9C7), width: 1.3),
            ),
            child: Icon(
              Icons.edit_rounded,
              color: const Color(0xFFD12788),
              size: 22 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.borderColor,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color borderColor;
  final Color foregroundColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      shape: CircleBorder(
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foregroundColor, size: iconSize),
        ),
      ),
    );
  }
}

class _SettingsMenuPanel extends StatelessWidget {
  const _SettingsMenuPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.username,
    required this.scale,
    required this.onAccountTap,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final String username;
  final double scale;
  final VoidCallback onAccountTap;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 4 * scale),
        _SettingsAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          scale: scale,
        ),
        SizedBox(height: 14 * scale),
        Text(
          username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _deepInk,
            fontFamily: 'Nunito',
            fontSize: 26 * scale,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 34 * scale),
        _SettingsActionCard(
          icon: Icons.account_circle_outlined,
          iconColor: const Color(0xFFC21873),
          iconBackground: const Color(0xFFFFF0F7),
          title: 'Tài Khoản',
          subtitle: 'Quản lý thông tin tài khoản',
          scale: scale,
          onTap: onAccountTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF008A52),
          iconBackground: const Color(0xFFD6FFE3),
          title: 'Hồ Sơ',
          subtitle: 'Xem và chỉnh sửa hồ sơ',
          scale: scale,
          onTap: onProfileTap,
        ),
        SizedBox(height: 12 * scale),
        _SettingsActionCard(
          icon: Icons.logout_rounded,
          iconColor: _orange,
          iconBackground: const Color(0xFFFFD8D8),
          title: 'Logout',
          subtitle: 'Đăng xuất khỏi tài khoản',
          isDestructive: true,
          scale: scale,
          onTap: () {
            HapticFeedback.selectionClick();
            onLogoutTap();
          },
        ),
      ],
    );
  }
}

class _SettingsAvatar extends StatelessWidget {
  const _SettingsAvatar({
    required this.avatarUrl,
    required this.avatarPath,
    required this.scale,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final path = avatarPath?.trim();
    final size = 118 * scale;

    Widget avatarChild;
    if (path != null && path.isNotEmpty) {
      avatarChild = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else if (url != null && url.isNotEmpty) {
      avatarChild = Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _AccountDefaultAvatar(scale: scale),
      );
    } else {
      avatarChild = Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Image.asset(
          'assets/images/welcome_numi_character.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return SizedBox(
      width: size + 22 * scale,
      height: size + 22 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(4 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF61AE),
                  width: 4 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF61AE).withValues(alpha: 0.18),
                    blurRadius: 16 * scale,
                    offset: Offset(0, 7 * scale),
                  ),
                ],
              ),
              child: ClipOval(child: avatarChild),
            ),
          ),
          Positioned(
            right: 6 * scale,
            bottom: 16 * scale,
            child: Container(
              width: 26 * scale,
              height: 26 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF55E66E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.scale,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final double scale;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0xFF5E7775).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          height: 78 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            children: [
              Container(
                width: 46 * scale,
                height: 46 * scale,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24 * scale),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDestructive ? _orange : _deepInk,
                        fontFamily: 'Nunito',
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 7 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF604950),
                        fontFamily: 'Nunito',
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFD5A8BA),
                size: 28 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountDetailsPanel extends StatelessWidget {
  const _AccountDetailsPanel({
    super.key,
    required this.avatarUrl,
    required this.avatarPath,
    required this.usernameController,
    required this.phoneController,
    required this.emailController,
    required this.isEditing,
    required this.isPickingAvatar,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onAvatarTap,
    required this.scale,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final TextEditingController usernameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final bool isEditing;
  final bool isPickingAvatar;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onAvatarTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedOpacity(
            opacity: isEditing ? 0 : 1,
            duration: const Duration(milliseconds: 160),
            child: _AccountEditButton(
              enabled: !isEditing,
              scale: scale,
              onTap: onEdit,
            ),
          ),
        ),
        SizedBox(height: isEditing ? 4 * scale : 6 * scale),
        _AccountAvatar(
          avatarUrl: avatarUrl,
          avatarPath: avatarPath,
          isEditing: isEditing,
          isPickingAvatar: isPickingAvatar,
          scale: scale,
          onCameraTap: onAvatarTap,
        ),
        SizedBox(height: 8 * scale),
        _AccountTextField(
          label: 'Username',
          controller: usernameController,
          isEditing: isEditing,
          trailing: Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF087A40),
            size: 19 * scale,
          ),
          scale: scale,
        ),
        SizedBox(height: 22 * scale),
        _AccountPhoneField(
          label: 'Số Điện Thoại',
          controller: phoneController,
          isEditing: isEditing,
          scale: scale,
        ),
        SizedBox(height: 22 * scale),
        _AccountTextField(
          label: 'Email',
          controller: emailController,
          isEditing: isEditing,
          keyboardType: TextInputType.emailAddress,
          scale: scale,
        ),
        if (isEditing) ...[
          SizedBox(height: 34 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CancelButton(
                scale: scale,
                onTap: onCancel,
              ),
              SizedBox(width: 14 * scale),
              _SaveButton(
                scale: scale,
                onTap: onSave,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({
    required this.avatarUrl,
    required this.avatarPath,
    required this.isEditing,
    required this.isPickingAvatar,
    required this.scale,
    required this.onCameraTap,
  });

  final String? avatarUrl;
  final String? avatarPath;
  final bool isEditing;
  final bool isPickingAvatar;
  final double scale;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final path = avatarPath?.trim();
    final size = 142 * scale;

    return Center(
      child: SizedBox(
        width: size + 30 * scale,
        height: size + 30 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(6 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF61AE),
                  width: 5 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF61AE).withValues(alpha: 0.20),
                    blurRadius: 18 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBDE6FF),
                    width: 5 * scale,
                  ),
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: path != null && path.isNotEmpty
                      ? Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _AccountDefaultAvatar(scale: scale);
                          },
                        )
                      : url == null || url.isEmpty
                          ? Padding(
                              padding: EdgeInsets.all(24 * scale),
                              child: Image.asset(
                                'assets/images/welcome_numi_character.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Padding(
                                  padding: EdgeInsets.all(24 * scale),
                                  child: Image.asset(
                                    'assets/images/welcome_numi_character.png',
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ),
            if (isPickingAvatar)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (isEditing)
              Positioned(
                right: 16 * scale,
                bottom: 20 * scale,
                child: _RoundIconButton(
                  icon: Icons.photo_camera_outlined,
                  size: 38 * scale,
                  iconSize: 20 * scale,
                  borderColor: const Color(0xFFC21873),
                  foregroundColor: const Color(0xFF253228),
                  backgroundColor: Colors.white,
                  onTap: onCameraTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountDefaultAvatar extends StatelessWidget {
  const _AccountDefaultAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24 * scale),
      child: Image.asset(
        'assets/images/welcome_numi_character.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AccountTextField extends StatelessWidget {
  const _AccountTextField({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.scale,
    this.trailing,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final double scale;
  final Widget? trailing;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return _AccountFieldShell(
      label: label,
      trailing: trailing,
      scale: scale,
      child: _PlainAccountTextField(
        controller: controller,
        enabled: isEditing,
        keyboardType: keyboardType,
        scale: scale,
      ),
    );
  }
}

class _AccountPhoneField extends StatelessWidget {
  const _AccountPhoneField({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.scale,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AccountFieldShell(
      label: label,
      scale: scale,
      child: Row(
        children: [
          Container(
            width: 28 * scale,
            height: 20 * scale,
            decoration: BoxDecoration(
              color: AppColors.vietnamRed,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
            child: Icon(
              Icons.star_rounded,
              color: const Color(0xFFFFE14D),
              size: 13 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Text(
            '+84',
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 17 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          Container(
            width: 1 * scale,
            height: 35 * scale,
            margin: EdgeInsets.symmetric(horizontal: 18 * scale),
            color: const Color(0xFFDCE5E3),
          ),
          Expanded(
            child: _PlainAccountTextField(
              controller: controller,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              scale: scale,
              textStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'Nunito',
                fontSize: 21 * scale,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountFieldShell extends StatelessWidget {
  const _AccountFieldShell({
    required this.label,
    required this.child,
    required this.scale,
    this.trailing,
  });

  final String label;
  final Widget child;
  final double scale;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF604950),
                  fontFamily: 'Nunito',
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        SizedBox(height: 12 * scale),
        Container(
          height: 68 * scale,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7F9),
            borderRadius: BorderRadius.circular(11 * scale),
            border: Border.all(
              color: const Color(0xFF0D0D0D).withValues(
                alpha: label == 'Số Điện Thoại' ? 0.38 : 0,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}

class _PlainAccountTextField extends StatelessWidget {
  const _PlainAccountTextField({
    required this.controller,
    required this.enabled,
    required this.scale,
    this.keyboardType,
    this.textStyle,
  });

  final TextEditingController controller;
  final bool enabled;
  final double scale;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 17 * scale,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        );

    return TextField(
      controller: controller,
      readOnly: !enabled,
      enableInteractiveSelection: enabled,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.done,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: style,
      decoration: const InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _teal,
      elevation: 9,
      shadowColor: Colors.black.withValues(alpha: 0.30),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 142 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lưu',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(width: 10 * scale),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD995),
      elevation: 0,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 138 * scale,
          height: 60 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                color: const Color(0xFFB74419),
                size: 20 * scale,
              ),
              SizedBox(width: 4 * scale),
              Text(
                'HỦY',
                style: TextStyle(
                  color: const Color(0xFFB74419),
                  fontFamily: 'Nunito',
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfilePanel extends StatelessWidget {
  const _AddProfilePanel({
    super.key,
    required this.nameController,
    required this.avatarPath,
    required this.avatarUrl,
    required this.grades,
    required this.programs,
    required this.semesters,
    required this.selectedGrade,
    required this.selectedProgram,
    required this.selectedSemester,
    required this.isLoadingOptions,
    required this.isPickingAvatar,
    required this.isSaving,
    required this.errorMessage,
    required this.canRetryOptions,
    required this.onPickAvatar,
    required this.onClearAvatar,
    required this.onGradeChanged,
    required this.onProgramChanged,
    required this.onSemesterChanged,
    required this.onRetryOptions,
    required this.onCancel,
    required this.onSave,
    required this.scale,
  });

  final TextEditingController nameController;
  final String? avatarPath;
  final String? avatarUrl;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SemesterModel> semesters;
  final GradeModel? selectedGrade;
  final ProgramModel? selectedProgram;
  final SemesterModel? selectedSemester;
  final bool isLoadingOptions;
  final bool isPickingAvatar;
  final bool isSaving;
  final String? errorMessage;
  final bool canRetryOptions;
  final VoidCallback onPickAvatar;
  final VoidCallback onClearAvatar;
  final ValueChanged<GradeModel?> onGradeChanged;
  final ValueChanged<ProgramModel?> onProgramChanged;
  final ValueChanged<SemesterModel?> onSemesterChanged;
  final VoidCallback onRetryOptions;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final error = errorMessage?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddProfileAvatar(
          avatarPath: avatarPath,
          avatarUrl: avatarUrl,
          isPicking: isPickingAvatar,
          scale: scale,
          onTap: onPickAvatar,
          onClear: onClearAvatar,
        ),
        SizedBox(height: 22 * scale),
        _AddProfileTextField(
          label: 'Họ Tên',
          controller: nameController,
          hintText: "Enter student's full name",
          scale: scale,
        ),
        SizedBox(height: 14 * scale),
        if (isLoadingOptions)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 58 * scale),
            child: Center(
              child: CircularProgressIndicator(
                color: _teal,
                strokeWidth: 3 * scale,
              ),
            ),
          )
        else ...[
          _AddProfileDropdown<GradeModel>(
            label: 'Lớp',
            hintText: 'Chọn lớp',
            value: selectedGrade,
            items: grades,
            itemLabel: (grade) => grade.label?.trim().isNotEmpty == true
                ? grade.label!.trim()
                : 'Lớp',
            onChanged: onGradeChanged,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _AddProfileDropdown<ProgramModel>(
            label: 'Chương Trình Học',
            hintText: 'Chọn chương trình',
            value: selectedProgram,
            items: programs,
            itemLabel: (program) => program.label?.trim().isNotEmpty == true
                ? program.label!.trim()
                : 'Chương trình',
            onChanged: onProgramChanged,
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _AddProfileDropdown<SemesterModel>(
            label: 'Học Kỳ',
            hintText: 'Chọn học kỳ',
            value: selectedSemester,
            items: semesters,
            itemLabel: (semester) => semester.name?.trim().isNotEmpty == true
                ? semester.name!.trim()
                : 'Học kỳ',
            onChanged: onSemesterChanged,
            scale: scale,
          ),
        ],
        if (error != null && error.isNotEmpty) ...[
          SizedBox(height: 14 * scale),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _orange,
              fontFamily: 'Nunito',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          if (canRetryOptions && !isSaving && !isLoadingOptions) ...[
            SizedBox(height: 10 * scale),
            Center(
              child: TextButton(
                onPressed: onRetryOptions,
                child: Text(
                  'Tải lại lựa chọn',
                  style: TextStyle(
                    color: _teal,
                    fontFamily: 'Nunito',
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ],
        SizedBox(height: 34 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CancelButton(scale: scale, onTap: isSaving ? () {} : onCancel),
            SizedBox(width: 14 * scale),
            Opacity(
              opacity: isSaving ? 0.72 : 1,
              child:
                  _SaveButton(scale: scale, onTap: isSaving ? () {} : onSave),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddProfileAvatar extends StatelessWidget {
  const _AddProfileAvatar({
    required this.avatarPath,
    required this.avatarUrl,
    required this.isPicking,
    required this.scale,
    required this.onTap,
    required this.onClear,
  });

  final String? avatarPath;
  final String? avatarUrl;
  final bool isPicking;
  final double scale;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath?.trim();
    final url = avatarUrl?.trim();
    final size = 116 * scale;

    return Center(
      child: SizedBox(
        width: size + 28 * scale,
        height: size + 28 * scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFE2EAED),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14 * scale,
                    offset: Offset(0, 6 * scale),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3 * scale),
              ),
              child: ClipOval(
                child: path != null && path.isNotEmpty
                    ? Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.person_rounded,
                            color: const Color(0xFFD3DEE1),
                            size: 56 * scale,
                          );
                        },
                      )
                    : url != null && url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Icon(
                                Icons.person_rounded,
                                color: const Color(0xFFD3DEE1),
                                size: 56 * scale,
                              );
                            },
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: const Color(0xFFD3DEE1),
                            size: 56 * scale,
                          ),
              ),
            ),
            if (isPicking)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            if (path != null && path.isNotEmpty)
              Positioned(
                left: 14 * scale,
                bottom: 18 * scale,
                child: Material(
                  color: const Color(0xFFFFD8D8),
                  elevation: 5,
                  shadowColor: const Color(0xFFE83434).withValues(alpha: 0.16),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onClear,
                    child: SizedBox(
                      width: 38 * scale,
                      height: 38 * scale,
                      child: Icon(
                        Icons.close_rounded,
                        color: const Color(0xFFE83434),
                        size: 22 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 14 * scale,
              bottom: 18 * scale,
              child: Material(
                color: const Color(0xFFFF61AE),
                elevation: 5,
                shadowColor: const Color(0xFFFF61AE).withValues(alpha: 0.28),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: SizedBox(
                    width: 38 * scale,
                    height: 38 * scale,
                    child: Icon(
                      Icons.photo_camera_outlined,
                      color: _deepInk,
                      size: 19 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileTextField extends StatelessWidget {
  const _AddProfileTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.scale,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AddProfileFieldShell(
      label: label,
      scale: scale,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        style: TextStyle(
          color: _deepInk,
          fontFamily: 'Nunito',
          fontSize: 15 * scale,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFFA8B1B2),
            fontFamily: 'Nunito',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _AddProfileDropdown<T> extends StatelessWidget {
  const _AddProfileDropdown({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    required this.scale,
  });

  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _AddProfileFieldShell(
      label: label,
      scale: scale,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFFB72D83),
            size: 24 * scale,
          ),
          hint: Text(
            hintText,
            style: TextStyle(
              color: const Color(0xFFA8B1B2),
              fontFamily: 'Nunito',
              fontSize: 15 * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(
            color: _deepInk,
            fontFamily: 'Nunito',
            fontSize: 15 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AddProfileFieldShell extends StatelessWidget {
  const _AddProfileFieldShell({
    required this.label,
    required this.child,
    required this.scale,
  });

  final String label;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF604950),
            fontFamily: 'Nunito',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          height: 54 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7F9),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: const Color(0xFFD8E4E7), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }
}

class _ProfilePlaceholderPanel extends StatelessWidget {
  const _ProfilePlaceholderPanel({
    super.key,
    required this.profiles,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.scale,
  });

  final List<StudentProfile> profiles;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final ValueChanged<StudentProfile> onEdit;
  final ValueChanged<StudentProfile> onDelete;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 360 * scale,
        child: Center(
          child: CircularProgressIndicator(
            color: _teal,
            strokeWidth: 3 * scale,
          ),
        ),
      );
    }

    final error = errorMessage?.trim();
    if (error != null && error.isNotEmpty) {
      return _ProfileStatePanel(
        icon: Icons.cloud_off_rounded,
        title: 'Không tải được hồ sơ',
        message: error,
        buttonLabel: 'Thử lại',
        scale: scale,
        onTap: onRetry,
      );
    }

    if (profiles.isEmpty) {
      return _ProfileStatePanel(
        icon: Icons.groups_2_outlined,
        title: 'Chưa có hồ sơ',
        message: 'Bạn có thể thêm hồ sơ học tập cho bé.',
        buttonLabel: 'Thêm hồ sơ',
        scale: scale,
        onTap: onAdd,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _ProfileAddButton(scale: scale, onTap: onAdd),
        ),
        SizedBox(height: 10 * scale),
        for (var index = 0; index < profiles.length; index++) ...[
          _ProfileCard(
            profile: profiles[index],
            isActive: profiles[index].isDefault || index == 0,
            scale: scale,
            onEdit: () => onEdit(profiles[index]),
            onDelete: () => onDelete(profiles[index]),
          ),
          if (index != profiles.length - 1) SizedBox(height: 22 * scale),
        ],
      ],
    );
  }
}

class _ProfileAddButton extends StatelessWidget {
  const _ProfileAddButton({
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFB72D83),
      elevation: 4,
      shadowColor: const Color(0xFFB72D83).withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(12 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: SizedBox(
          width: 48 * scale,
          height: 34 * scale,
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24 * scale,
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.scale,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentProfile profile;
  final bool isActive;
  final double scale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? const Color(0xFFC21873) : const Color(0xFF008A52);

    return Container(
      padding:
          EdgeInsets.fromLTRB(20 * scale, 18 * scale, 16 * scale, 18 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(
          color: isActive
              ? const Color(0xFFFF61AE)
              : const Color(0xFFDAEAE5).withValues(alpha: 0.78),
          width: isActive ? 2 * scale : 1 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E7775).withValues(alpha: 0.08),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(
                avatarUrl: profile.avatarUrl,
                scale: scale,
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 13 * scale,
                    vertical: 7 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF61A4FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: const Color(0xFF003C88),
                      fontFamily: 'Nunito',
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 18 * scale),
          Text(
            _displayProfileName(profile),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 18 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 17 * scale),
          _ProfileInfoLine(
            icon: Icons.school_outlined,
            iconColor: accent,
            label: 'Lớp',
            value: _displayGrade(profile),
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _ProfileInfoLine(
            icon: Icons.book_outlined,
            iconColor: accent,
            label: 'Chương Trình',
            value: _displayProgram(profile),
            scale: scale,
          ),
          SizedBox(height: 14 * scale),
          _ProfileInfoLine(
            icon: Icons.calendar_month_outlined,
            iconColor: accent,
            label: 'Học Kỳ',
            value: _displaySemester(profile),
            scale: scale,
          ),
          SizedBox(height: 18 * scale),
          Row(
            children: [
              _ProfileIconButton(
                icon: Icons.edit_rounded,
                foregroundColor: const Color(0xFFD12788),
                backgroundColor: const Color(0xFFECF6FA),
                scale: scale,
                onTap: onEdit,
              ),
              SizedBox(width: 12 * scale),
              _ProfileIconButton(
                icon: Icons.delete_outline_rounded,
                foregroundColor: const Color(0xFFE83434),
                backgroundColor: const Color(0xFFFFD8D8),
                scale: scale,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _displayProfileName(StudentProfile profile) {
    final name = profile.name?.trim();
    return name == null || name.isEmpty ? 'Bé yêu' : name;
  }

  static String _displayGrade(StudentProfile profile) {
    final grade = profile.grade?.label?.trim();
    return grade == null || grade.isEmpty ? 'Chưa chọn' : grade;
  }

  static String _displayProgram(StudentProfile profile) {
    final program = profile.program?.label?.trim();
    return program == null || program.isEmpty ? 'Chưa chọn' : program;
  }

  static String _displaySemester(StudentProfile profile) {
    final semester = profile.semester?.name?.trim();
    return semester == null || semester.isEmpty ? 'Chưa chọn' : semester;
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.avatarUrl,
    required this.scale,
  });

  final String? avatarUrl;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final size = 84 * scale;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD5C6),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFF61AE),
          width: 4 * scale,
        ),
      ),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? Padding(
                padding: EdgeInsets.all(14 * scale),
                child: Image.asset(
                  'assets/images/welcome_numi_character.png',
                  fit: BoxFit.contain,
                ),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Padding(
                    padding: EdgeInsets.all(14 * scale),
                    child: Image.asset(
                      'assets/images/welcome_numi_character.png',
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ProfileInfoLine extends StatelessWidget {
  const _ProfileInfoLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.scale,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18 * scale),
        SizedBox(width: 8 * scale),
        Text(
          '$label : ',
          style: TextStyle(
            color: const Color(0xFF604950),
            fontFamily: 'Nunito',
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF604950),
              fontFamily: 'Nunito',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  const _ProfileIconButton({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10 * scale),
        child: SizedBox(
          width: 42 * scale,
          height: 42 * scale,
          child: Icon(icon, color: foregroundColor, size: 23 * scale),
        ),
      ),
    );
  }
}

class _ProfileStatePanel extends StatelessWidget {
  const _ProfileStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.scale,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 360 * scale),
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFA2B1A3).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _teal, size: 54 * scale),
          SizedBox(height: 18 * scale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _deepInk,
              fontFamily: 'Nunito',
              fontSize: 22 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontFamily: 'Nunito',
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 20 * scale),
          Material(
            color: _teal,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 22 * scale,
                  vertical: 12 * scale,
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
