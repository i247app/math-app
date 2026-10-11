import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/data/app_failure.dart';
import 'package:numi/core/data/async_resource.dart';
import 'package:numi/core/data/session_cache_scope.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/profile.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/avatar/avatar_picker_service.dart';
import 'package:numi/features/auth/models/auth_models.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/shared/helpers/teacher_profile_option_helpers.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/classroom/data/teacher_classroom_lookup_cache.dart';
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
  final UserProfile? activeProfile;
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

  AsyncResource<TeacherClassroomLookupOptions> _optionsResource =
      const AsyncResource.idle();
  int _optionsRevision = 0;
  int _identityRevision = 0;
  bool _isSubmitting = false;
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
    _identityRevision++;
    _optionsRevision++;
    _nameController.removeListener(_markDraftDirty);
    _descriptionController.removeListener(_markDraftDirty);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TeacherCreateClassScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id == widget.user?.id &&
        profileStableId(oldWidget.activeProfile) ==
            profileStableId(widget.activeProfile)) {
      return;
    }
    _identityRevision++;
    _optionsRevision++;
    _optionsResource = const AsyncResource.idle();
    _grades = const [];
    _programs = const [];
    _schools = const [];
    _selectedGrade = null;
    _selectedPrograms = const [];
    _selectedSchool = null;
    _avatarPath = null;
    _nameController.clear();
    _descriptionController.clear();
    _isDraftDirty = false;
    _isSubmitting = false;
    _loadOptions();
  }

  Future<void> _loadOptions({bool forceRefresh = false}) async {
    final revision = ++_optionsRevision;
    final identity = _identityRevision;
    final scope = SessionCacheScope.current;
    final userId = widget.user?.id;
    bool current() =>
        mounted &&
        revision == _optionsRevision &&
        identity == _identityRevision &&
        scope.isCurrent;
    if (userId == null || userId <= 0) {
      setState(
        () => _optionsResource = AsyncResource.failed(
          const AppFailure(
            type: AppFailureType.validation,
            code: AppKeys.missingAccount,
          ),
        ),
      );
      return;
    }
    final cachedOptions = TeacherClassroomLookupCache.shared.get(userId);
    if (!forceRefresh && cachedOptions != null) {
      _applyOptions(
        cachedOptions,
        preserveSelections: _optionsResource.hasData,
      );
      _optionsResource = AsyncResource.ready(
        cachedOptions,
        updatedAt: DateTime.now(),
      );
    }
    final previous = _optionsResource;
    setState(() => _optionsResource = previous.refreshing());
    try {
      final options = await TeacherClassroomLookupCache.shared.load(
        userId: userId,
        gradeService: _gradeService,
        profileService: _profileService,
        schoolService: _schoolService,
        forceRefresh: forceRefresh || cachedOptions != null,
      );
      if (!current()) return;
      setState(() {
        _applyOptions(options, preserveSelections: previous.hasData);
        _optionsResource = AsyncResource.ready(
          options,
          updatedAt: DateTime.now(),
        );
      });
    } catch (error) {
      if (!current()) return;
      setState(
        () => _optionsResource = AsyncResource.failed(
          AppFailure.fromException(error),
          data: previous.data,
          hasData: previous.hasData,
        ),
      );
    }
  }

  void _applyOptions(
    TeacherClassroomLookupOptions options, {
    bool preserveSelections = false,
  }) {
    final gradeId = preserveSelections
        ? gradeStableId(_selectedGrade)
        : widget.activeProfile?.gradeId;
    final schoolId = preserveSelections
        ? schoolStableId(_selectedSchool)
        : widget.activeProfile?.schoolId;
    final programIds = _selectedPrograms
        .map(programStableId)
        .whereType<int>()
        .toSet();
    _grades = options.grades;
    _programs = options.programs;
    _schools = options.schools;
    _selectedGrade =
        matchGrade(_grades, gradeId) ??
        (_grades.isEmpty ? null : _grades.first);
    _selectedPrograms = preserveSelections
        ? _programs
              .where((program) => programIds.contains(programStableId(program)))
              .toList(growable: false)
        : const [];
    _selectedSchool =
        matchSchool(_schools, schoolId) ??
        (_schools.isEmpty ? null : _schools.first);
  }

  Future<void> _pickAvatar() async {
    final identity = _identityRevision;
    final scope = SessionCacheScope.current;
    try {
      final avatarPath = await _avatarPicker.pickAvatarPath();
      if (!mounted ||
          identity != _identityRevision ||
          !scope.isCurrent ||
          avatarPath == null ||
          avatarPath.isEmpty) {
        return;
      }
      setState(() {
        _avatarPath = avatarPath;
        _isDraftDirty = true;
      });
    } catch (_) {
      if (!mounted || identity != _identityRevision || !scope.isCurrent) return;
      _showError(context.readText(AppKeys.imagePickFailed));
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final identity = _identityRevision;
    final scope = SessionCacheScope.current;
    bool current() =>
        mounted && identity == _identityRevision && scope.isCurrent;
    final profileId = profileStableId(widget.activeProfile);
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
      if (!mounted || !current()) {
        return;
      }
      context.read<ClassroomCubit>().invalidateOwned(profileId);
      await _exitController.exitWithResult(
        TeacherCreateClassResult(classroom: classroom),
      );
    } on ClassroomException catch (error) {
      if (current()) _showError(error.message);
    } catch (_) {
      if (mounted && current()) {
        _showError(context.readText(AppKeys.teacherCreateClassFailed));
      }
    } finally {
      if (current()) {
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
    if (_optionsResource.isInitialLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: context.themeColors.brandStrong,
        ),
      );
    }
    final failure = _optionsResource.failure;
    final optionsError = failure == null
        ? null
        : context.getText(
            failure.code == AppKeys.missingAccount
                ? AppKeys.missingAccount
                : AppKeys.teacherCreateOptionsFailed,
          );
    if (optionsError != null && !_optionsResource.hasData) {
      return TeacherFullScreenError(
        message: optionsError,
        onRetry: () => _loadOptions(forceRefresh: true),
      );
    }
    final form = TeacherCreateClassForm(
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
    if (optionsError == null) return form;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
          child: AppRetryPanel(
            message: optionsError,
            onRetry: () => _loadOptions(forceRefresh: true),
          ),
        ),
        Expanded(child: form),
      ],
    );
  }
}
