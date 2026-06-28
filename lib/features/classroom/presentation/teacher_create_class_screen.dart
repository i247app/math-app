part of 'teacher_classroom_screens.dart';

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
  })  : _classroomService = classroomService,
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

  Future<void> _loadOptions() async {
    final userId = widget.user?.id;
    if (userId == null || userId <= 0) {
      setState(() {
        _isLoadingOptions = false;
        _optionsError = context.readText(AppKeys.missingAccount);
      });
      return;
    }

    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });

    try {
      final results = await Future.wait<Object>([
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _schoolService.listSchools(),
      ]);
      final grades = results[0] as List<GradeModel>;
      final programs = results[1] as List<ProgramModel>;
      final schools = results[2] as List<SchoolModel>;
      if (!mounted) {
        return;
      }
      setState(() {
        _grades = grades;
        _programs = programs;
        _schools = schools;
        _selectedGrade = _matchGrade(grades, widget.activeProfile?.gradeId) ??
            (grades.isEmpty ? null : grades.first);
        _selectedPrograms = const <ProgramModel>[];
        _selectedSchool =
            _matchSchool(schools, widget.activeProfile?.schoolId) ??
                (schools.isEmpty ? null : schools.first);
      });
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

  Future<void> _pickAvatar() async {
    try {
      final avatarPath = await _avatarPicker.pickAvatarPath();
      if (!mounted || avatarPath == null || avatarPath.isEmpty) {
        return;
      }
      setState(() => _avatarPath = avatarPath);
    } catch (_) {
      _showSnack(context.readText(AppKeys.imagePickFailed));
    }
  }

  Future<void> _submit() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    final gradeId = _gradeStableId(_selectedGrade);
    final programIds = _selectedPrograms
        .map(_programStableId)
        .whereType<int>()
        .toList(growable: false);
    final schoolId = _schoolStableId(_selectedSchool);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (profileId == null) {
      _showSnack(context.readText(AppKeys.teacherMissingProfileId));
      return;
    }
    if (name.isEmpty ||
        gradeId == null ||
        programIds.isEmpty ||
        schoolId == null) {
      _showSnack(context.readText(AppKeys.teacherClassMissingInfo));
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
      Navigator.of(context)
          .pop(_TeacherCreateClassResult(classroom: classroom));
    } on ClassroomException catch (error) {
      _showSnack(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(constraints.maxWidth / 390, 1.12);
            return Column(
              children: [
                _TeacherScreenAppBar(
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
      return const Center(
        child: CircularProgressIndicator(color: _teacherTeal),
      );
    }
    final optionsError = _optionsError;
    if (optionsError != null) {
      return _TeacherFullScreenError(
        message: optionsError,
        onRetry: _loadOptions,
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
      onProgramsChanged: (values) => setState(
        () => _selectedPrograms = values,
      ),
      onSchoolChanged: (value) => setState(() => _selectedSchool = value),
      onSubmit: _submit,
    );
  }
}
