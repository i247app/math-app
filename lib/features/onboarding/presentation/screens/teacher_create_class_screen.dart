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
  ProgramModel? _selectedProgram;
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
    final userId = widget.user?.id.trim();
    if (userId == null || userId.isEmpty) {
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
        _selectedProgram =
            _matchProgram(programs, widget.activeProfile?.programId) ??
                (programs.isEmpty ? null : programs.first);
        _selectedSchool =
            _matchSchool(schools, widget.activeProfile?.schoolId) ??
                (schools.isEmpty ? null : schools.first);
      });
    } catch (error) {
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
    final programId = _programStableId(_selectedProgram);
    final schoolId = _schoolStableId(_selectedSchool);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (profileId == null || profileId.isEmpty) {
      _showSnack(context.readText(AppKeys.teacherMissingProfileId));
      return;
    }
    if (name.isEmpty ||
        gradeId == null ||
        programId == null ||
        schoolId == null) {
      _showSnack(context.readText(AppKeys.teacherClassMissingInfo));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _classroomService.createClassroom(
        profileId: profileId,
        name: name,
        gradeId: gradeId,
        programId: programId,
        schoolId: schoolId,
        description: description.isEmpty ? null : description,
        filePath: _avatarPath,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
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
                Expanded(
                  child: _isLoadingOptions
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _teacherTeal,
                          ),
                        )
                      : _optionsError != null
                          ? _TeacherFullScreenError(
                              message: _optionsError!,
                              onRetry: _loadOptions,
                              scale: scale,
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                28 * scale,
                                24 * scale,
                                28 * scale,
                                24 * scale,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ClassAvatarPicker(
                                    scale: scale,
                                    avatarPath: _avatarPath,
                                    onTap: _pickAvatar,
                                  ),
                                  SizedBox(height: 20 * scale),
                                  _TeacherDropdownField<GradeModel>(
                                    label: context
                                        .getText(AppKeys.teacherGradeLevel),
                                    value: _selectedGrade,
                                    items: _grades,
                                    displayText: _gradeLabel,
                                    onChanged: (value) =>
                                        setState(() => _selectedGrade = value),
                                    scale: scale,
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _TeacherTextField(
                                    label: context
                                        .getText(AppKeys.teacherClassName),
                                    hintText: context.getText(
                                      AppKeys.teacherClassNameHint,
                                    ),
                                    controller: _nameController,
                                    scale: scale,
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _TeacherDropdownField<ProgramModel>(
                                    label: context
                                        .getText(AppKeys.learningProgram),
                                    value: _selectedProgram,
                                    items: _programs,
                                    displayText: _programLabel,
                                    onChanged: (value) => setState(
                                        () => _selectedProgram = value),
                                    scale: scale,
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _TeacherDropdownField<SchoolModel>(
                                    label: context.getText(AppKeys.school),
                                    value: _selectedSchool,
                                    items: _schools,
                                    displayText: _schoolLabel,
                                    onChanged: (value) =>
                                        setState(() => _selectedSchool = value),
                                    scale: scale,
                                    outlined: true,
                                  ),
                                  SizedBox(height: 14 * scale),
                                  _TeacherTextField(
                                    label: context.getText(
                                      AppKeys.teacherClassDescription,
                                    ),
                                    hintText: context.getText(
                                      AppKeys.teacherClassDescriptionHint,
                                    ),
                                    controller: _descriptionController,
                                    scale: scale,
                                    maxLines: 4,
                                  ),
                                  SizedBox(height: 28 * scale),
                                  Center(
                                    child: _TeacherPrimaryButton(
                                      label: _isSubmitting
                                          ? context.getText(
                                              AppKeys.teacherCreating,
                                            )
                                          : context.getText(
                                              AppKeys.teacherCreate,
                                            ),
                                      icon: Icons.arrow_forward_rounded,
                                      width: 230 * scale,
                                      height: 56 * scale,
                                      scale: scale,
                                      onPressed: _isSubmitting ? null : _submit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
