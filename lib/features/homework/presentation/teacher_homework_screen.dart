part of '../../classroom/presentation/teacher_classroom_screens.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.userId,
    this.initialClassroom,
    this.purpose = classroomExercisePurposeHomework,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final int? userId;
  final ClassroomModel? initialClassroom;
  final String purpose;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        purpose: widget.purpose,
      );
      if (!mounted) {
        return;
      }
      setState(() => _exercises = exercises);
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message.trim().isEmpty
            ? context.readText(
                _teacherExerciseCopy(widget.purpose).listLoadFailedKey,
              )
            : error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateHomework() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TeacherCreateHomeworkScreen(
          classroomId: widget.classroomId,
          profileId: widget.profileId,
          userId: widget.userId,
          initialClassroom: widget.initialClassroom,
          purpose: widget.purpose,
          exerciseService: _exerciseService,
          classroomService: ClassroomApi(),
        ),
      ),
    );
    if (created == true) {
      await _loadExercises();
    }
  }

  void _openExerciseDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: widget.profileId,
          initialExercise: exercise,
          purpose: widget.purpose,
          exerciseService: _exerciseService,
        ),
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
              title: context.getText(
                _teacherExerciseCopy(widget.purpose).titleKey,
              ),
              scale: 1,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: _teacherTeal,
                onRefresh: _loadExercises,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    19,
                    30,
                    19,
                    MediaQuery.paddingOf(context).bottom + 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _TeacherHomeworkAddButton(
                          onTap: _openCreateHomework,
                        ),
                      ),
                      const SizedBox(height: 33),
                      const _TeacherHomeworkSearchField(),
                      const SizedBox(height: 24),
                      _TeacherHomeworkSectionHeader(purpose: widget.purpose),
                      const SizedBox(height: 17),
                      if (_isLoading && _exercises.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _teacherTeal,
                            ),
                          ),
                        )
                      else if (_error != null && _exercises.isEmpty)
                        _TeacherErrorPanel(
                          scale: 1,
                          message: _error!,
                          onRetry: _loadExercises,
                        )
                      else if (_exercises.isEmpty)
                        _TeacherEmptyAssignmentsPanel(
                          message: context.getText(
                            _teacherExerciseCopy(widget.purpose).emptyKey,
                          ),
                        )
                      else ...[
                        for (var index = 0;
                            index < _exercises.length;
                            index++) ...[
                          _TeacherAssignmentCard(
                            exercise: _exercises[index],
                            onTap: () => _openExerciseDetail(
                              _exercises[index],
                            ),
                          ),
                          if (index != _exercises.length - 1)
                            const SizedBox(height: 10),
                        ],
                        if (_isLoading)
                          const _TeacherBackgroundRefreshLabel(scale: 1),
                      ],
                    ],
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

class _TeacherHomeworkAddButton extends StatelessWidget {
  const _TeacherHomeworkAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _teacherCoral,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 91,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                bottom: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: SvgPicture.asset(
                  'assets/images/teacher_homework_add.svg',
                  width: 12,
                  height: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherHomeworkSearchField extends StatelessWidget {
  const _TeacherHomeworkSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      padding: const EdgeInsets.fromLTRB(26, 0, 18, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Text(
              context.getText(AppKeys.teacherAssignmentSearchHint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFFDCBFC8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            'assets/images/teacher_homework_filter.svg',
            width: 18,
            height: 18,
          ),
        ],
      ),
    );
  }
}

class _TeacherHomeworkSectionHeader extends StatelessWidget {
  const _TeacherHomeworkSectionHeader({required this.purpose});

  final String purpose;

  @override
  Widget build(BuildContext context) {
    final copy = _teacherExerciseCopy(purpose);
    return Row(
      children: [
        Expanded(
          child: Text(
            context.getText(copy.createdTitleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: _teacherBlue,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 28 / 20,
            ),
          ),
        ),
        SvgPicture.asset(
          'assets/images/teacher_homework_sort.svg',
          width: 16,
          height: 16,
        ),
        const SizedBox(width: 4),
        Text(
          context.getText(AppKeys.teacherAssignmentNewest),
          style: GoogleFonts.andika(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}

class _TeacherExerciseCopy {
  const _TeacherExerciseCopy({
    required this.titleKey,
    required this.createdTitleKey,
    required this.listLoadFailedKey,
    required this.detailLoadFailedKey,
    required this.createFailedKey,
    required this.emptyKey,
    required this.createTitleKey,
    required this.createdMessageKey,
    required this.titleHintKey,
    required this.descriptionHintKey,
  });

  final String titleKey;
  final String createdTitleKey;
  final String listLoadFailedKey;
  final String detailLoadFailedKey;
  final String createFailedKey;
  final String emptyKey;
  final String createTitleKey;
  final String createdMessageKey;
  final String titleHintKey;
  final String descriptionHintKey;
}

_TeacherExerciseCopy _teacherExerciseCopy(String purpose) {
  if (purpose.trim().toUpperCase() == classroomExercisePurposeExam) {
    return const _TeacherExerciseCopy(
      titleKey: AppKeys.teacherAssessments,
      createdTitleKey: AppKeys.teacherCreatedAssessments,
      listLoadFailedKey: AppKeys.teacherAssessmentListLoadFailed,
      detailLoadFailedKey: AppKeys.teacherAssessmentDetailLoadFailed,
      createFailedKey: AppKeys.teacherAssessmentCreateFailed,
      emptyKey: AppKeys.teacherNoAssessments,
      createTitleKey: AppKeys.teacherCreateAssessmentTitle,
      createdMessageKey: AppKeys.teacherAssessmentCreated,
      titleHintKey: AppKeys.teacherAssessmentTitleHint,
      descriptionHintKey: AppKeys.teacherAssessmentDescriptionHint,
    );
  }

  return const _TeacherExerciseCopy(
    titleKey: AppKeys.teacherAssignments,
    createdTitleKey: AppKeys.teacherCreatedAssignments,
    listLoadFailedKey: AppKeys.teacherAssignmentListLoadFailed,
    detailLoadFailedKey: AppKeys.teacherAssignmentDetailLoadFailed,
    createFailedKey: AppKeys.teacherAssignmentCreateFailed,
    emptyKey: AppKeys.teacherNoAssignments,
    createTitleKey: AppKeys.teacherCreateAssignmentTitle,
    createdMessageKey: AppKeys.teacherAssignmentCreated,
    titleHintKey: AppKeys.teacherAssignmentTitleHint,
    descriptionHintKey: AppKeys.teacherAssignmentDescriptionHint,
  );
}

class _TeacherAssignmentCard extends StatelessWidget {
  const _TeacherAssignmentCard({
    required this.exercise,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = _teacherExerciseDateParts(exercise.endDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 82,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEFF6FF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dateParts.day,
                      style: GoogleFonts.andika(
                        color: _teacherBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      dateParts.month,
                      style: GoogleFonts.andika(
                        color: const Color(0xFF6B7280),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _teacherExerciseTitle(context, exercise),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 17.5 / 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.formatText(
                          AppKeys.teacherAssignmentId,
                          {'id': exerciseId},
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'assets/images/teacher_homework_more.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherEmptyAssignmentsPanel extends StatelessWidget {
  const _TeacherEmptyAssignmentsPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9EC)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.andika(
          color: _teacherMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

void _showTeacherHomeworkSoon(BuildContext context) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.getText(AppKeys.teacherCreateAssignmentSoon)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
}

String _teacherExerciseTitle(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final title = exercise?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }
  final id = exercise?.stableId;
  if (id != null) {
    return context.formatText(AppKeys.teacherAssignmentId, {'id': id});
  }
  return '';
}

String _teacherExerciseQuestionCount(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final count = exercise?.numQuestions ?? exercise?.questions.length;
  if (count != null && count > 0) {
    return context.formatText(
      AppKeys.teacherAssignmentQuestionCountFormat,
      {'count': count},
    );
  }
  return '';
}

String _teacherExerciseDueDate(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  return _teacherExerciseDateTimeLabel(exercise?.endDate) ?? '';
}

String? _teacherExerciseDateTimeLabel(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return '${_twoDigits(local.hour)}:${_twoDigits(local.minute)} '
      '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year}';
}

_TeacherExerciseDateParts _teacherExerciseDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return const _TeacherExerciseDateParts(day: '23', month: 'TH10');
  }
  final local = parsed.toLocal();
  return _TeacherExerciseDateParts(
    day: _twoDigits(local.day),
    month: 'TH${_twoDigits(local.month)}',
  );
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class _TeacherExerciseDateParts {
  const _TeacherExerciseDateParts({
    required this.day,
    required this.month,
  });

  final String day;
  final String month;
}
