part of 'teacher_classroom_screens.dart';

class TeacherCreateHomeworkScreen extends StatefulWidget {
  const TeacherCreateHomeworkScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.userId,
    this.initialClassroom,
    ClassroomExerciseService? exerciseService,
    ClassroomService? classroomService,
    GradeService? gradeService,
    ProfileService? profileService,
    SchoolService? schoolService,
  })  : _exerciseService = exerciseService,
        _classroomService = classroomService,
        _gradeService = gradeService,
        _profileService = profileService,
        _schoolService = schoolService;

  final int classroomId;
  final int profileId;
  final int? userId;
  final ClassroomModel? initialClassroom;
  final ClassroomExerciseService? _exerciseService;
  final ClassroomService? _classroomService;
  final GradeService? _gradeService;
  final ProfileService? _profileService;
  final SchoolService? _schoolService;

  @override
  State<TeacherCreateHomeworkScreen> createState() =>
      _TeacherCreateHomeworkScreenState();
}

class _TeacherCreateHomeworkScreenState
    extends State<TeacherCreateHomeworkScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _lessonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final ProfileService _profileService =
      widget._profileService ?? ProfileApi();
  late final SchoolService _schoolService =
      widget._schoolService ?? SchoolApi();
  late ClassroomModel? _selectedClassroom = widget.initialClassroom;
  int? _selectedProgramId;
  DateTime? _startDate;
  DateTime? _endDate;
  List<ClassroomModel> _classrooms = const <ClassroomModel>[];
  List<GradeModel> _grades = const <GradeModel>[];
  List<ProgramModel> _programs = const <ProgramModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];
  bool _isLoadingClassrooms = false;
  bool _isLoadingSelectedClassroom = false;
  bool _isLoadingLookups = false;
  String _visibility = 'PUBLIC';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
    _loadLookupOptions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _chapterController.dispose();
    _lessonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    if (!_validateCreateHomeworkForm()) {
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _isSubmitting = true);
    try {
      await _exerciseService.createExercise(
        profileId: widget.profileId,
        classroomId: _selectedClassroomId,
        programId: _selectedProgramId!,
        title: _trimOrDefault(
          _titleController.text,
          'Phép cộng trong phạm vi 20',
        ),
        numQuestions: 4,
        chapterName: _trimOrDefault(_chapterController.text, 'Phép cộng'),
        lessonName: _trimOrDefault(
          _lessonController.text,
          'Các số trong phạm vi 20',
        ),
        visibility: _visibility,
        startDate: _exerciseApiDate(_startDate!),
        endDate: _exerciseApiDate(_endDate!),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.getText(AppKeys.teacherAssignmentCreated)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1400),
          ),
        );
      Navigator.of(context).pop(true);
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(
        error.message.trim().isEmpty
            ? context.readText(AppKeys.teacherAssignmentCreateFailed)
            : error.message,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int get _selectedClassroomId =>
      _selectedClassroom?.stableId ?? widget.classroomId;

  bool _validateCreateHomeworkForm() {
    final now = DateTime.now();
    if (_selectedProgramId == null) {
      _showSnack(context.readText(AppKeys.teacherAssignmentProgramRequired));
      return false;
    }
    if (_startDate == null) {
      _showSnack(context.readText(AppKeys.teacherAssignmentStartDateRequired));
      return false;
    }
    if (_endDate == null) {
      _showSnack(context.readText(AppKeys.teacherAssignmentEndDateRequired));
      return false;
    }
    if (!_startDate!.isAfter(now) || !_endDate!.isAfter(now)) {
      _showSnack(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return false;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      _showSnack(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return false;
    }
    return true;
  }

  Future<void> _loadClassrooms() async {
    if (_isLoadingClassrooms) {
      return;
    }

    setState(() => _isLoadingClassrooms = true);
    try {
      final classrooms = await _classroomService.listClassrooms(
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _classrooms = _mergeSelectedClassroom(classrooms, _selectedClassroom);
        _selectedClassroom =
            _matchingClassroom(_classrooms, _selectedClassroomId) ??
                _selectedClassroom;
        _selectedProgramId = _validProgramIdForClassroom(
          _selectedClassroom,
          _selectedProgramId,
          _programs,
        );
      });
      await _loadSelectedClassroomDetail();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoadingClassrooms = false);
      }
    }
  }

  Future<void> _loadSelectedClassroomDetail() async {
    if (_isLoadingSelectedClassroom) {
      return;
    }

    final classroomId = _selectedClassroomId;
    setState(() => _isLoadingSelectedClassroom = true);
    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: classroomId,
        profileId: widget.profileId,
      );
      if (!mounted || classroom == null) {
        return;
      }
      setState(() {
        _selectedClassroom = classroom;
        _selectedProgramId = _validProgramIdForClassroom(
          classroom,
          _selectedProgramId,
          _programs,
        );
      });
    } on ClassroomException catch (error) {
      if (mounted) {
        _showSnack(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSelectedClassroom = false);
      }
    }
  }

  Future<void> _loadLookupOptions() async {
    final userId = widget.userId;
    if (userId == null || userId <= 0) {
      return;
    }

    setState(() => _isLoadingLookups = true);
    try {
      final results = await Future.wait<Object>([
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _schoolService.listSchools(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _grades = results[0] as List<GradeModel>;
        _programs = results[1] as List<ProgramModel>;
        _schools = results[2] as List<SchoolModel>;
        _selectedProgramId = _validProgramIdForClassroom(
          _selectedClassroom,
          _selectedProgramId,
          _programs,
        );
      });
    } catch (_) {
      // Keep the form usable with classroom ids if lookup endpoints fail.
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  Future<void> _openClassSelector() async {
    if (_classrooms.isEmpty) {
      await _loadClassrooms();
    }
    if (!mounted || _classrooms.isEmpty) {
      if (mounted) {
        _showSnack(context.readText(AppKeys.teacherNoOptions));
      }
      return;
    }

    final selected = await showModalBottomSheet<ClassroomModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return _CreateHomeworkClassBottomSheet(
          classrooms: _classrooms,
          selectedClassroomId: _selectedClassroomId,
          bottomInset: bottomInset,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedClassroom = selected;
      _selectedProgramId = null;
    });
    await _loadSelectedClassroomDetail();
  }

  Future<void> _openProgramSelector() async {
    final options = _programOptionsForClassroom(
      context,
      _selectedClassroom,
      _programs,
    );
    if (options.isEmpty) {
      _showSnack(context.readText(AppKeys.teacherNoOptions));
      return;
    }

    final selected = await showModalBottomSheet<_ClassroomProgramOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return _CreateHomeworkProgramBottomSheet(
          options: options,
          selectedProgramId: _selectedProgramId,
          bottomInset: bottomInset,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() => _selectedProgramId = selected.id);
  }

  Future<void> _openDatePicker({required bool isStart}) async {
    final now = DateTime.now();
    final minimum = now.add(const Duration(minutes: 1));
    final currentValue = isStart ? _startDate : _endDate;
    final endMinimum = _startDate?.add(const Duration(minutes: 1));
    final baseInitial = currentValue ??
        (isStart
            ? minimum.add(const Duration(hours: 1))
            : endMinimum ?? minimum.add(const Duration(days: 1)));
    final initialDateTime =
        baseInitial.isAfter(minimum) ? baseInitial : minimum;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        initialDateTime.year,
        initialDateTime.month,
        initialDateTime.day,
      ),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, now.month, now.day),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (pickedTime == null || !mounted) {
      return;
    }

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    if (!selected.isAfter(now)) {
      _showSnack(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return;
    }
    if (isStart && _endDate != null && !selected.isBefore(_endDate!)) {
      _showSnack(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return;
    }
    if (!isStart && _startDate != null && !selected.isAfter(_startDate!)) {
      _showSnack(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TeacherScreenAppBar(
              title: context.getText(AppKeys.teacherCreateAssignmentTitle),
              scale: 1,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  14,
                  15,
                  14,
                  MediaQuery.paddingOf(context).bottom + 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 362),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CreateHomeworkClassSelector(
                          classroom: _selectedClassroom,
                          isLoading: _isLoadingClassrooms,
                          onTap: _openClassSelector,
                        ),
                        const SizedBox(height: 10),
                        _CreateHomeworkClassSummary(
                          classroom: _selectedClassroom,
                          grades: _grades,
                          programs: _programs,
                          schools: _schools,
                          isLoading: _isLoadingClassrooms ||
                              _isLoadingSelectedClassroom ||
                              _isLoadingLookups,
                        ),
                        const SizedBox(height: 22),
                        _CreateHomeworkInput(
                          controller: _titleController,
                          hintKey: AppKeys.teacherAssignmentTitleHint,
                          height: 62,
                          radius: 10,
                        ),
                        const SizedBox(height: 13),
                        _CreateHomeworkLabel(
                          context
                              .getText(AppKeys.teacherAssignmentProgramLabel),
                        ),
                        const SizedBox(height: 9),
                        _CreateHomeworkSelectField(
                          valueKey: AppKeys.teacherAssignmentProgramLabel,
                          valueText: _selectedHomeworkProgramName(
                            context,
                            _programs,
                            _selectedProgramId,
                          ),
                          radius: 12,
                          borderColor: const Color(0xFFC4C6D2),
                          borderWidth: 1,
                          iconAsset:
                              'assets/images/teacher_homework_dropdown.svg',
                          iconWidth: 12,
                          iconHeight: 8,
                          onTap: _openProgramSelector,
                        ),
                        const SizedBox(height: 18),
                        _CreateHomeworkLabel(
                          context.getText(AppKeys.teacherAssignmentDeadline),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _CreateHomeworkDateField(
                                hintKey: AppKeys.teacherAssignmentStartDateHint,
                                valueText: _formatCreateHomeworkDate(
                                  _startDate,
                                ),
                                onTap: () => _openDatePicker(isStart: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _CreateHomeworkDateField(
                                hintKey: AppKeys.teacherAssignmentEndDateHint,
                                valueText: _formatCreateHomeworkDate(_endDate),
                                onTap: () => _openDatePicker(isStart: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _CreateHomeworkLabeledInput(
                                labelKey: AppKeys.teacherAssignmentChapterLabel,
                                controller: _chapterController,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CreateHomeworkLabeledInput(
                                labelKey: AppKeys.teacherAssignmentLessonLabel,
                                controller: _lessonController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        _CreateHomeworkInput(
                          controller: _descriptionController,
                          hintKey: AppKeys.teacherAssignmentDescriptionHint,
                          height: 167,
                          maxLines: 6,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                        const SizedBox(height: 24),
                        _CreateHomeworkPublishSwitch(
                          isPublished: _visibility == 'PUBLIC',
                          onChanged: (isPublished) {
                            setState(
                              () => _visibility =
                                  isPublished ? 'PUBLIC' : 'PRIVATE',
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: _CreateHomeworkSubmitButton(
                            isLoading: _isSubmitting,
                            onTap: _submit,
                          ),
                        ),
                      ],
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

class _CreateHomeworkClassSelector extends StatelessWidget {
  const _CreateHomeworkClassSelector({
    required this.classroom,
    required this.isLoading,
    required this.onTap,
  });

  final ClassroomModel? classroom;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.fromLTRB(18, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDE4E6), width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _createHomeworkClassName(context, classroom),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _teacherTeal,
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/images/teacher_homework_dropdown.svg',
                  width: 12,
                  height: 8,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateHomeworkClassBottomSheet extends StatelessWidget {
  const _CreateHomeworkClassBottomSheet({
    required this.classrooms,
    required this.selectedClassroomId,
    required this.bottomInset,
  });

  final List<ClassroomModel> classrooms;
  final int selectedClassroomId;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E9EC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              context.getText(AppKeys.teacherAssignmentSelectClass),
              style: GoogleFonts.andika(
                color: _teacherTeal,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: classrooms.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFEFF4F5),
                ),
                itemBuilder: (context, index) {
                  final classroom = classrooms[index];
                  final classroomId = classroom.stableId;
                  final isSelected = classroomId == selectedClassroomId;
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _createHomeworkClassName(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherInk,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _createHomeworkStudentCount(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: _teacherTeal,
                              size: 22,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(classroom),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateHomeworkProgramBottomSheet extends StatelessWidget {
  const _CreateHomeworkProgramBottomSheet({
    required this.options,
    required this.selectedProgramId,
    required this.bottomInset,
  });

  final List<_ClassroomProgramOption> options;
  final int? selectedProgramId;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E9EC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              context.getText(AppKeys.teacherAssignmentProgramLabel),
              style: GoogleFonts.andika(
                color: _teacherTeal,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFEFF4F5),
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.id == selectedProgramId;
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherInk,
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: _teacherTeal,
                              size: 22,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateHomeworkClassSummary extends StatelessWidget {
  const _CreateHomeworkClassSummary({
    required this.classroom,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.isLoading,
  });

  final ClassroomModel? classroom;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 15, 25, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: isLoading
          ? const SizedBox(
              height: 108,
              child: Center(
                child: CircularProgressIndicator(color: _teacherTeal),
              ),
            )
          : Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 71,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE4EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/teacher_class_graduation.svg',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _createHomeworkStudentCount(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 29),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _createHomeworkClassSummaryName(context, classroom),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherInk,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 32 / 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_grade.png',
                        label: _createHomeworkGradeName(
                            context, classroom, grades),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset: 'assets/images/teacher_class_program.png',
                        label: _createHomeworkProgramName(
                          context,
                          classroom,
                          programs,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _CreateHomeworkClassMeta(
                        iconAsset:
                            'assets/images/teacher_class_description.png',
                        label: _createHomeworkSchoolName(
                            context, classroom, schools),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _CreateHomeworkClassMeta extends StatelessWidget {
  const _CreateHomeworkClassMeta({
    required this.iconAsset,
    required this.label,
  });

  final String iconAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconAsset,
          width: 18,
          height: 18,
          opacity: const AlwaysStoppedAnimation<double>(0.7),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _teacherBlue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateHomeworkLabeledInput extends StatelessWidget {
  const _CreateHomeworkLabeledInput({
    required this.labelKey,
    required this.controller,
  });

  final String labelKey;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CreateHomeworkLabel(context.getText(labelKey)),
        const SizedBox(height: 8),
        _CreateHomeworkInput(
          controller: controller,
          hintKey: labelKey,
          height: 51,
        ),
      ],
    );
  }
}

class _CreateHomeworkLabel extends StatelessWidget {
  const _CreateHomeworkLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.andika(
        color: const Color(0xFF564148),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 20 / 14,
      ),
    );
  }
}

class _CreateHomeworkInput extends StatelessWidget {
  const _CreateHomeworkInput({
    required this.controller,
    required this.hintKey,
    required this.height,
    this.radius = 16,
    this.maxLines = 1,
    this.textAlignVertical = TextAlignVertical.center,
  });

  final TextEditingController controller;
  final String hintKey;
  final double height;
  final double radius;
  final int maxLines;
  final TextAlignVertical textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: textAlignVertical,
        style: GoogleFonts.andika(
          color: _teacherInk,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: context.getText(hintKey),
          hintStyle: GoogleFonts.andika(
            color: _teacherInk.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(
              color: Color(0xFFDDE4E6),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(
              color: _teacherTeal,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateHomeworkPublishSwitch extends StatelessWidget {
  const _CreateHomeworkPublishSwitch({
    required this.isPublished,
    required this.onChanged,
  });

  final bool isPublished;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.getText(AppKeys.teacherAssignmentPublishLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _teacherInk,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 18 / 14,
            ),
          ),
        ),
        Text(
          context.getText(
            isPublished
                ? AppKeys.teacherAssignmentVisibilityPublic
                : AppKeys.teacherAssignmentVisibilityPrivate,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: _teacherInk.withValues(alpha: 0.65),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: isPublished,
          activeThumbColor: Colors.white,
          activeTrackColor: _teacherTeal,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFC4C6D2),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CreateHomeworkSelectField extends StatelessWidget {
  const _CreateHomeworkSelectField({
    required this.onTap,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    this.valueKey,
    this.valueText,
    this.radius = 8,
    this.borderColor = const Color(0xFFDDE4E6),
    this.borderWidth = 2,
  });

  final String? valueKey;
  final String? valueText;
  final VoidCallback onTap;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final text = valueText ?? context.getText(valueKey!);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: 56,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.andika(
                    color: _teacherInk.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SvgPicture.asset(
                iconAsset,
                width: iconWidth,
                height: iconHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateHomeworkDateField extends StatelessWidget {
  const _CreateHomeworkDateField({
    required this.hintKey,
    required this.onTap,
    this.valueText,
  });

  final String hintKey;
  final VoidCallback onTap;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    return _CreateHomeworkSelectField(
      valueKey: hintKey,
      valueText: valueText,
      iconAsset: 'assets/images/teacher_homework_create_calendar.svg',
      iconWidth: 18,
      iconHeight: 20,
      onTap: onTap,
    );
  }
}

class _CreateHomeworkSubmitButton extends StatelessWidget {
  const _CreateHomeworkSubmitButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _teacherTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.getText(AppKeys.teacherCreate).toUpperCase(),
                    style: GoogleFonts.andika(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 16 / 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 5),
                  SvgPicture.asset(
                    'assets/images/teacher_homework_create_arrow.svg',
                    width: 14,
                    height: 14,
                  ),
                ],
              ),
      ),
    );
  }
}

String _trimOrDefault(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String? _formatCreateHomeworkDate(DateTime? value) {
  if (value == null) {
    return null;
  }
  return '${_twoDigits(value.day)}/${_twoDigits(value.month)}/${value.year} '
      '${_twoDigits(value.hour)}:${_twoDigits(value.minute)}';
}

String _exerciseApiDate(DateTime value) {
  final utc = value.toUtc();
  final micros = utc.millisecond * 1000 + utc.microsecond;
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${_twoDigits(utc.month)}-'
      '${_twoDigits(utc.day)}T'
      '${_twoDigits(utc.hour)}:'
      '${_twoDigits(utc.minute)}:'
      '${_twoDigits(utc.second)}.'
      '${micros.toString().padLeft(6, '0')}Z';
}

String _createHomeworkClassName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassOption)
      : name;
}

String _createHomeworkClassSummaryName(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final name = classroom?.name?.trim();
  return name == null || name.isEmpty
      ? context.getText(AppKeys.teacherAssignmentClassSummaryName)
      : name;
}

String _createHomeworkStudentCount(
  BuildContext context,
  ClassroomModel? classroom,
) {
  final count = classroom?.displayStudentCount;
  if (count == null || count <= 0) {
    return context.getText(AppKeys.teacherAssignmentClassStudentCount);
  }
  return context.formatText(
    AppKeys.teacherAssignmentClassStudentCountFormat,
    {'count': count},
  );
}

String _createHomeworkGradeName(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = _matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return _gradeLabel(grade);
  }
  final gradeId = classroom?.gradeId;
  if (gradeId != null) {
    return '${context.getText(AppKeys.grade)} ${_displayBackendId(gradeId)}';
  }
  return context.getText(AppKeys.teacherAssignmentClassGrade);
}

String _createHomeworkProgramName(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs, {
  int? selectedProgramId,
}) {
  final options = _programOptionsForClassroom(context, classroom, programs);
  if (selectedProgramId == null && options.isNotEmpty) {
    return options.map((option) => option.label).join(', ');
  }

  final selectedId = selectedProgramId ?? _defaultProgramId(classroom);
  for (final option in options) {
    if (option.id == selectedId) {
      return option.label;
    }
  }

  return context.getText(AppKeys.teacherProgramFallback);
}

String? _selectedHomeworkProgramName(
  BuildContext context,
  List<ProgramModel> programs,
  int? selectedProgramId,
) {
  if (selectedProgramId == null) {
    return null;
  }
  final program = _matchProgram(programs, selectedProgramId);
  if (program != null) {
    return _programLabel(program);
  }
  return '${context.getText(AppKeys.teacherProgramFallback)} '
      '$selectedProgramId';
}

String _createHomeworkSchoolName(
  BuildContext context,
  ClassroomModel? classroom,
  List<SchoolModel> schools,
) {
  final school = _matchSchool(schools, classroom?.schoolId);
  if (school != null) {
    return _schoolLabel(school);
  }
  return _displayBackendId(classroom?.schoolId) ??
      context.getText(AppKeys.school);
}

int? _defaultProgramId(ClassroomModel? classroom) {
  if (classroom?.programId != null) {
    return classroom!.programId;
  }
  final programIds = classroom?.programIds ?? const <int>[];
  return programIds.isEmpty ? null : programIds.first;
}

int? _validProgramIdForClassroom(
  ClassroomModel? classroom,
  int? selectedProgramId,
  List<ProgramModel> programs,
) {
  final options = _programOptionsForClassroomWithoutContext(
    classroom,
    programs,
  );
  if (selectedProgramId == null) {
    return null;
  }
  if (options.isEmpty ||
      options.any((option) => option.id == selectedProgramId)) {
    return selectedProgramId;
  }
  return null;
}

List<_ClassroomProgramOption> _programOptionsForClassroom(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final options = _programOptionsForClassroomWithoutContext(
    classroom,
    programs,
  );
  if (options.isEmpty) {
    return const <_ClassroomProgramOption>[];
  }
  return options.map((option) {
    if (option.label.isNotEmpty) {
      return option;
    }
    return _ClassroomProgramOption(
      id: option.id,
      label: '${context.getText(AppKeys.teacherProgramFallback)} ${option.id}',
    );
  }).toList(growable: false);
}

List<_ClassroomProgramOption> _programOptionsForClassroomWithoutContext(
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  if (classroom == null) {
    return const <_ClassroomProgramOption>[];
  }

  final ids = <int>[
    if (classroom.programId != null) classroom.programId!,
    for (final id in classroom.programIds)
      if (id != classroom.programId) id,
  ];
  if (ids.isEmpty) {
    return const <_ClassroomProgramOption>[];
  }

  return ids.map((id) {
    final program = _matchProgram(programs, id);
    return _ClassroomProgramOption(
      id: id,
      label: program == null ? '' : _programLabel(program),
    );
  }).toList(growable: false);
}

class _ClassroomProgramOption {
  const _ClassroomProgramOption({
    required this.id,
    required this.label,
  });

  final int id;
  final String label;
}

List<ClassroomModel> _mergeSelectedClassroom(
  List<ClassroomModel> classrooms,
  ClassroomModel? selectedClassroom,
) {
  final selectedId = selectedClassroom?.stableId;
  if (selectedClassroom == null ||
      selectedId == null ||
      _matchingClassroom(classrooms, selectedId) != null) {
    return classrooms;
  }
  return <ClassroomModel>[selectedClassroom, ...classrooms];
}

ClassroomModel? _matchingClassroom(
  List<ClassroomModel> classrooms,
  int classroomId,
) {
  for (final classroom in classrooms) {
    if (classroom.stableId == classroomId) {
      return classroom;
    }
  }
  return null;
}
