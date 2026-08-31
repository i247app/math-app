import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/avatar/avatar_picker_service.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/shared/helpers/teacher_profile_option_helpers.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/classroom/data/cache/teacher_classroom_lookup_cache.dart';
import 'package:numi/features/classroom/widgets/teacher_create/teacher_create_class_form.dart';
import 'package:numi/features/classroom/widgets/teacher_create/teacher_create_class_result.dart';
import 'package:numi/features/classroom/widgets/teacher_shared/teacher_full_screen_error.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

class TeacherCreateClassScreen extends StatefulWidget {
  const TeacherCreateClassScreen({
    super.key,
    required this.user,
    required this.activeProfile,
    ClassroomService? classroomService,
    GradeService? gradeService,
    ProfileService? profileService,
    SchoolService? schoolService,
    AvatarPickerService? avatarPicker,
  }) : _classroomService = classroomService,
       _gradeService = gradeService,
       _profileService = profileService,
       _schoolService = schoolService,
       _avatarPicker = avatarPicker;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final ClassroomService? _classroomService;
  final GradeService? _gradeService;
  final ProfileService? _profileService;
  final SchoolService? _schoolService;
  final AvatarPickerService? _avatarPicker;

  @override
  State<TeacherCreateClassScreen> createState() =>
      _TeacherCreateClassScreenState();
}

class _TeacherCreateClassScreenState extends State<TeacherCreateClassScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? context.read<ClassroomService>();
  late final GradeService _gradeService =
      widget._gradeService ?? context.read<GradeService>();
  late final ProfileService _profileService =
      widget._profileService ?? context.read<ProfileService>();
  late final SchoolService _schoolService =
      widget._schoolService ?? context.read<SchoolService>();
  late final AvatarPickerService _avatarPicker =
      widget._avatarPicker ?? const AvatarPickerService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GuardedExitController<TeacherCreateClassResult> _exitController =
      GuardedExitController<TeacherCreateClassResult>();

  bool _isLoadingOptions = true;
  bool _isSubmitting = false;
  String? _optionsError;
  String? _avatarPath;
  List<GradeModel> _grades = const <GradeModel>[];
  List<ProgramModel> _programs = const <ProgramModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];
  GradeModel? _selectedGrade;
  List<ProgramModel> _selectedPrograms = const <ProgramModel>[];
  SchoolModel? _selectedSchool;
  bool _isDraftDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_markDraftDirty);
    _descriptionController.addListener(_markDraftDirty);
    _loadOptions();
  }

  @override
  void dispose() {
    _nameController.removeListener(_markDraftDirty);
    _descriptionController.removeListener(_markDraftDirty);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions({bool forceRefresh = false}) async {
    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoadingOptions = false;
        _optionsError = context.readText(AppKeys.missingAccount);
      });
      return;
    }

    final cachedOptions = TeacherClassroomLookupCache.shared.get(userId);
    if (!forceRefresh && cachedOptions != null) {
      setState(() {
        _applyOptions(cachedOptions);
        _isLoadingOptions = false;
        _optionsError = null;
      });
      unawaited(_loadOptions(forceRefresh: true));
      return;
    }

    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });

    try {
      final options = await TeacherClassroomLookupCache.shared.load(
        userId: userId,
        gradeService: _gradeService,
        profileService: _profileService,
        schoolService: _schoolService,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      setState(() => _applyOptions(options));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _optionsError = context.readText(
          AppKeys.teacherCreateOptionsFailed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingOptions = false);
      }
    }
  }

  void _applyOptions(TeacherClassroomLookupOptions options) {
    _grades = options.grades;
    _programs = options.programs;
    _schools = options.schools;
    _selectedGrade =
        matchGrade(_grades, widget.activeProfile?.gradeId) ??
        (_grades.isEmpty ? null : _grades.first);
    _selectedPrograms = const <ProgramModel>[];
    _selectedSchool =
        matchSchool(_schools, widget.activeProfile?.schoolId) ??
        (_schools.isEmpty ? null : _schools.first);
  }

  Future<void> _pickAvatar() async {
    try {
      final avatarPath = await _avatarPicker.pickAvatarPath();
      if (!mounted || avatarPath == null || avatarPath.isEmpty) {
        return;
      }
      setState(() {
        _avatarPath = avatarPath;
        _isDraftDirty = true;
      });
    } catch (_) {
      _showError(context.readText(AppKeys.imagePickFailed));
    }
  }

  Future<void> _submit() async {
    final profileId = ActiveProfileSession.profileStableId(
      widget.activeProfile,
    );
    final gradeId = gradeStableId(_selectedGrade);
    final programIds = _selectedPrograms
        .map(programStableId)
        .whereType<int>()
        .toList(growable: false);
    final schoolId = schoolStableId(_selectedSchool);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (profileId == null) {
      _showError(context.readText(AppKeys.teacherMissingProfileId));
      return;
    }
    if (name.isEmpty ||
        gradeId == null ||
        programIds.isEmpty ||
        schoolId == null) {
      _showError(context.readText(AppKeys.teacherClassMissingInfo));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final classroom = await _classroomService.createClassroom(
        profileId: profileId,
        name: name,
        gradeId: gradeId,
        programIds: programIds,
        schoolId: schoolId,
        description: description.isEmpty ? null : description,
        filePath: _avatarPath,
      );
      if (!mounted) {
        return;
      }
      context.read<ClassroomCubit>().invalidateOwned(profileId);
      await _exitController.exitWithResult(
        TeacherCreateClassResult(classroom: classroom),
      );
    } on ClassroomException catch (error) {
      _showError(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    context.showErrorDialog(message);
  }

  void _markDraftDirty() {
    if (!_isDraftDirty && mounted) {
      setState(() => _isDraftDirty = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final screen = Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenAppBar(
              backIconAsset: 'assets/icons/teacher-class-back.svg',
              title: context.getText(AppKeys.teacherCreateClassTitle),
              onBack: _exitController.requestExit,
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );

    return GuardedExitScope<TeacherCreateClassResult>(
      controller: _exitController,
      shouldConfirm: _isDraftDirty,
      isExitBlocked: _isSubmitting,
      confirmExit: showUnsavedChangesExitDialog,
      child: screen,
    );
  }

  Widget _buildContent() {
    if (_isLoadingOptions) {
      return Center(
        child: CircularProgressIndicator(
          color: context.themeColors.brandStrong,
        ),
      );
    }
    final optionsError = _optionsError;
    if (optionsError != null) {
      return TeacherFullScreenError(
        message: optionsError,
        onRetry: () => _loadOptions(forceRefresh: true),
      );
    }
    return TeacherCreateClassForm(
      avatarPath: _avatarPath,
      grades: _grades,
      programs: _programs,
      schools: _schools,
      selectedGrade: _selectedGrade,
      selectedPrograms: _selectedPrograms,
      selectedSchool: _selectedSchool,
      nameController: _nameController,
      descriptionController: _descriptionController,
      isSubmitting: _isSubmitting,
      onPickAvatar: _pickAvatar,
      onGradeChanged: (value) {
        setState(() {
          _selectedGrade = value;
          _isDraftDirty = true;
        });
      },
      onProgramsChanged: (values) {
        setState(() {
          _selectedPrograms = values;
          _isDraftDirty = true;
        });
      },
      onSchoolChanged: (value) {
        setState(() {
          _selectedSchool = value;
          _isDraftDirty = true;
        });
      },
      onSubmit: _submit,
    );
  }
}
