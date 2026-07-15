part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

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
      widget._classroomService ?? ClassroomApi();
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final ProfileService _profileService =
      widget._profileService ?? ProfileApi();
  late final SchoolService _schoolService =
      widget._schoolService ?? SchoolApi();
  late final AvatarPickerService _avatarPicker =
      widget._avatarPicker ?? const AvatarPickerService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
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

    final cachedOptions = _TeacherClassroomLookupCache.shared.get(userId);
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
      final options = await _TeacherClassroomLookupCache.shared.load(
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

  void _applyOptions(_TeacherClassroomLookupOptions options) {
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
      setState(() => _avatarPath = avatarPath);
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
      Navigator.of(context).pop(TeacherCreateClassResult(classroom: classroom));
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

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(constraints.maxWidth / 390, 1.12);
            return Column(
              children: [
                AppScreenAppBar(
                  backIconAsset: 'assets/images/teacher_class_back.svg',
                  title: context.getText(AppKeys.teacherCreateClassTitle),
                  scale: scale,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(child: _buildContent(scale)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(double scale) {
    if (_isLoadingOptions) {
      return Center(
        child: CircularProgressIndicator(
          color: context.themeColors.brandStrong,
        ),
      );
    }
    final optionsError = _optionsError;
    if (optionsError != null) {
      return _TeacherFullScreenError(
        message: optionsError,
        onRetry: () => _loadOptions(forceRefresh: true),
        scale: scale,
      );
    }
    return _TeacherCreateClassForm(
      scale: scale,
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
      onGradeChanged: (value) => setState(() => _selectedGrade = value),
      onProgramsChanged: (values) => setState(() => _selectedPrograms = values),
      onSchoolChanged: (value) => setState(() => _selectedSchool = value),
      onSubmit: _submit,
    );
  }
}
