part of '../../classroom/presentation/teacher_classroom_screens.dart';

class TeacherStudyTab extends StatefulWidget {
  const TeacherStudyTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    required this.scale,
    ClassroomService? classroomService,
    ClassroomExerciseService? exerciseService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  })  : _classroomService = classroomService,
        _exerciseService = exerciseService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final double scale;
  final int activeRefreshTick;
  final bool isActive;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherStudyTab> createState() => _TeacherStudyTabState();
}

class _TeacherStudyTabState extends State<TeacherStudyTab> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _exerciseRequestId = 0;
  int? _loadedProfileId;
  int? _selectedClassroomId;
  String _selectedPurpose = classroomExercisePurposeHomework;
  bool _isLoadingExercises = false;
  bool _hasCompletedInitialLoad = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];

  ClassroomCollectionState get _classroomCollection {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().owned(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoadingClassrooms => _classroomCollection.isLoading;

  String? get _displayError => _classroomCollection.errorMessage ?? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant TeacherStudyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _selectedClassroomId = null;
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms({bool forceRefresh = false}) async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    _exerciseRequestId++;
    final isInitialProfileLoad =
        !_hasCompletedInitialLoad || profileId != _loadedProfileId;
    if (profileId == null) {
      setState(() {
        _loadedProfileId = null;
        _exercises = const <ClassroomExercise>[];
        _error = context.readText(AppKeys.teacherMissingProfileId);
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    setState(() {
      _loadedProfileId = profileId;
      _isLoadingExercises = true;
      if (isInitialProfileLoad) {
        _hasCompletedInitialLoad = false;
        _exercises = const <ClassroomExercise>[];
      }
      _error = null;
    });

    final collection = await context.read<ClassroomCubit>().loadOwned(
          profileId,
          forceRefresh: forceRefresh,
        );
    if (!mounted || profileId != _loadedProfileId) {
      return;
    }

    final selectedStillExists = _selectedClassroomId == null ||
        collection.classrooms.any(
          (classroom) => classroom.stableId == _selectedClassroomId,
        );
    if (!selectedStillExists) {
      _selectedClassroomId = null;
    }
    if (collection.errorMessage != null && collection.classrooms.isEmpty) {
      setState(() {
        _exercises = const <ClassroomExercise>[];
        _error = collection.errorMessage!.trim().isEmpty
            ? context.readText(AppKeys.teacherStudyLoadFailed)
            : collection.errorMessage;
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }
    await _loadExercises();
  }

  Future<void> _refreshClassrooms() {
    return _loadClassrooms(forceRefresh: true);
  }

  Future<void> _loadExercises() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId == null || _isLoadingClassrooms) {
      return;
    }

    final requestId = ++_exerciseRequestId;
    final classrooms = _selectedClassroomId == null
        ? _classrooms
        : _classrooms
            .where(
              (classroom) => classroom.stableId == _selectedClassroomId,
            )
            .toList(growable: false);
    final targets = classrooms
        .where((classroom) => classroom.stableId != null)
        .toList(growable: false);

    if (targets.isEmpty) {
      setState(() {
        _exercises = const <ClassroomExercise>[];
        _error = null;
        _isLoadingExercises = false;
        _hasCompletedInitialLoad = true;
      });
      return;
    }

    setState(() {
      _isLoadingExercises = true;
      _error = null;
    });

    final search = _searchController.text.trim();
    final batches = await Future.wait(
      targets.map(
        (classroom) => _loadExerciseBatch(
          classroomId: classroom.stableId!,
          profileId: profileId,
          search: search,
          purpose: _selectedPurpose,
        ),
      ),
    );
    if (!mounted ||
        requestId != _exerciseRequestId ||
        profileId != _loadedProfileId) {
      return;
    }

    final exercises = <ClassroomExercise>[];
    String? firstError;
    for (final batch in batches) {
      exercises.addAll(batch.exercises);
      firstError ??= batch.error;
    }
    exercises.sort(_compareTeacherStudyExercises);

    setState(() {
      _exercises = _deduplicateTeacherStudyExercises(exercises);
      _error = exercises.isEmpty ? firstError : null;
      _isLoadingExercises = false;
      _hasCompletedInitialLoad = true;
    });
  }

  Future<_TeacherStudyExerciseBatch> _loadExerciseBatch({
    required int classroomId,
    required int profileId,
    required String search,
    required String purpose,
  }) async {
    final fallbackError = context.readText(AppKeys.teacherStudyLoadFailed);
    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: classroomId,
        profileId: profileId,
        search: search,
        purpose: purpose,
      );
      return _TeacherStudyExerciseBatch(exercises: exercises);
    } on ClassroomExerciseException catch (error) {
      return _TeacherStudyExerciseBatch(
        error: error.message.trim().isEmpty ? fallbackError : error.message,
      );
    } catch (_) {
      return _TeacherStudyExerciseBatch(error: fallbackError);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      _loadExercises,
    );
  }

  void _selectClassroom(int? classroomId) {
    if (_selectedClassroomId == classroomId) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedClassroomId = classroomId);
    _loadExercises();
  }

  void _selectPurpose(String purpose) {
    if (_selectedPurpose == purpose) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedPurpose = purpose);
    _loadExercises();
  }

  Future<void> _openCreateExercise() async {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    final classroom = _createClassroomSelection;
    final classroomId = classroom?.stableId;
    if (profileId == null || classroom == null || classroomId == null) {
      _showSnack(context.readText(AppKeys.teacherNoOptions));
      return;
    }

    HapticFeedback.lightImpact();
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => TeacherCreateHomeworkScreen(
          classroomId: classroomId,
          profileId: profileId,
          userId: widget.user?.id,
          initialClassroom: classroom,
          purpose: _selectedPurpose,
          exerciseService: _exerciseService,
          classroomService: _classroomService,
        ),
      ),
    );
    if (created == true) {
      await _loadExercises();
    }
  }

  ClassroomModel? get _createClassroomSelection {
    if (_selectedClassroomId != null) {
      for (final classroom in _classrooms) {
        if (classroom.stableId == _selectedClassroomId) {
          return classroom;
        }
      }
    }
    for (final classroom in _classrooms) {
      if (classroom.stableId != null) {
        return classroom;
      }
    }
    return null;
  }

  void _openExerciseDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (exerciseId == null || profileId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }

    final purpose = exercise.purpose?.trim().toUpperCase();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkDetailScreen(
          exerciseId: exerciseId,
          profileId: profileId,
          initialExercise: exercise,
          purpose: purpose == classroomExercisePurposeExam
              ? classroomExercisePurposeExam
              : purpose == classroomExercisePurposeHomework
                  ? classroomExercisePurposeHomework
                  : _selectedPurpose,
          exerciseService: _exerciseService,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final profileId =
        ActiveProfileSession.profileStableId(widget.activeProfile);
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final scale = widget.scale;
    final visibleExercises = _exercises.take(10).toList(growable: false);
    return ColoredBox(
      color: const Color(0xFFF9FFFF),
      child: Column(
        children: [
          _TeacherStudyHeader(
            scale: scale,
          ),
          Expanded(
            child: RefreshIndicator(
              color: _teacherTeal,
              onRefresh: _refreshClassrooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  19 * scale,
                  18 * scale,
                  19 * scale,
                  widget.bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _TeacherHomeworkAddButton(
                        onTap: _openCreateExercise,
                      ),
                    ),
                    SizedBox(height: 18 * scale),
                    _TeacherStudySearchField(
                      controller: _searchController,
                      scale: scale,
                      onChanged: _onSearchChanged,
                    ),
                    SizedBox(height: 14 * scale),
                    if (!_hasCompletedInitialLoad)
                      _TeacherStudyLoadingIndicator(scale: scale)
                    else ...[
                      _TeacherStudyClassFilters(
                        classrooms: _classrooms,
                        selectedClassroomId: _selectedClassroomId,
                        scale: scale,
                        onSelected: _selectClassroom,
                      ),
                      SizedBox(height: 14 * scale),
                      _TeacherStudyPurposeFilters(
                        selectedPurpose: _selectedPurpose,
                        scale: scale,
                        onSelected: _selectPurpose,
                      ),
                      SizedBox(height: 24 * scale),
                      if (_isLoadingExercises &&
                          _exercises.isEmpty &&
                          !_hasCompletedInitialLoad)
                        _TeacherStudyLoadingIndicator(scale: scale)
                      else if (_displayError != null && _exercises.isEmpty)
                        _TeacherErrorPanel(
                          scale: scale,
                          message: _displayError!,
                          onRetry: _refreshClassrooms,
                        )
                      else if (_classrooms.isEmpty)
                        Column(
                          children: [
                            _TeacherEmptyAssignmentsPanel(
                              message: context.getText(
                                AppKeys.teacherEmptyClassroomList,
                              ),
                            ),
                          ],
                        )
                      else if (_exercises.isEmpty)
                        Column(
                          children: [
                            _TeacherEmptyAssignmentsPanel(
                              message: _searchController.text.trim().isNotEmpty
                                  ? context.getText(
                                      AppKeys.teacherStudyNoResults,
                                    )
                                  : context.getText(
                                      _teacherExerciseCopy(
                                        _selectedPurpose,
                                      ).emptyKey,
                                    ),
                            ),
                          ],
                        )
                      else ...[
                        for (var index = 0;
                            index < visibleExercises.length;
                            index++) ...[
                          _TeacherStudyExerciseCard(
                            exercise: visibleExercises[index],
                            scale: scale,
                            onTap: () => _openExerciseDetail(
                              visibleExercises[index],
                            ),
                          ),
                          if (index != visibleExercises.length - 1)
                            SizedBox(height: 14 * scale),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherStudyLoadingIndicator extends StatelessWidget {
  const _TeacherStudyLoadingIndicator({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 36 * scale),
      child: const Center(
        child: CircularProgressIndicator(color: _teacherTeal),
      ),
    );
  }
}

class _TeacherStudyHeader extends StatelessWidget {
  const _TeacherStudyHeader({
    required this.scale,
  });

  final double scale;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      height: topInset + 60 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFF2F2F2),
            width: 4 * scale,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topInset + 6 * scale,
        18 * scale,
        6 * scale,
      ),
      child: Row(
        children: [
          SizedBox(width: 40 * scale),
          Expanded(
            child: Text(
              context.getText(AppKeys.teacherStudyTitle),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF339395),
                fontSize: FontSize.xxxl,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          SizedBox(width: 40 * scale),
        ],
      ),
    );
  }
}

class _TeacherStudySearchField extends StatelessWidget {
  const _TeacherStudySearchField({
    required this.controller,
    required this.scale,
    required this.onChanged,
  });

  final TextEditingController controller;
  final double scale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49 * scale,
      padding: EdgeInsets.fromLTRB(22 * scale, 0, 16 * scale, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFCCCCCC).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/teacher_homework_search.svg',
            width: 18 * scale,
            height: 18 * scale,
          ),
          SizedBox(width: 18 * scale),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              textInputAction: TextInputAction.search,
              style: GoogleFonts.andika(
                color: _teacherInk,
                fontSize: FontSize.normal * scale,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.getText(AppKeys.teacherAssignmentSearchHint),
                hintStyle: GoogleFonts.andika(
                  color: const Color(0xFFDCBFC8),
                  fontSize: FontSize.normal * scale,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          SvgPicture.asset(
            'assets/images/teacher_homework_filter.svg',
            width: 18 * scale,
            height: 18 * scale,
          ),
        ],
      ),
    );
  }
}

class _TeacherStudyClassFilters extends StatelessWidget {
  const _TeacherStudyClassFilters({
    required this.classrooms,
    required this.selectedClassroomId,
    required this.scale,
    required this.onSelected,
  });

  final List<ClassroomModel> classrooms;
  final int? selectedClassroomId;
  final double scale;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: classrooms.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 7 * scale),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _TeacherStudyFilterChip(
              label: context.getText(AppKeys.teacherStudyAllClasses),
              selected: selectedClassroomId == null,
              scale: scale,
              onTap: () => onSelected(null),
            );
          }
          final classroom = classrooms[index - 1];
          final classroomId = classroom.stableId;
          final name = classroom.name?.trim();
          return _TeacherStudyFilterChip(
            label: name?.isNotEmpty == true
                ? name!
                : context.getText(AppKeys.teacherClassFallback),
            selected: classroomId != null && classroomId == selectedClassroomId,
            scale: scale,
            onTap: classroomId == null ? null : () => onSelected(classroomId),
          );
        },
      ),
    );
  }
}

class _TeacherStudyPurposeFilters extends StatelessWidget {
  const _TeacherStudyPurposeFilters({
    required this.selectedPurpose,
    required this.scale,
    required this.onSelected,
  });

  final String selectedPurpose;
  final double scale;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssignments),
          selected: selectedPurpose == classroomExercisePurposeHomework,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeHomework),
        ),
        SizedBox(width: 8 * scale),
        _TeacherStudyFilterChip(
          label: context.getText(AppKeys.teacherAssessments),
          selected: selectedPurpose == classroomExercisePurposeExam,
          scale: scale,
          onTap: () => onSelected(classroomExercisePurposeExam),
        ),
      ],
    );
  }
}

class _TeacherStudyFilterChip extends StatelessWidget {
  const _TeacherStudyFilterChip({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: BoxConstraints(minWidth: 80 * scale),
          height: 43 * scale,
          padding: EdgeInsets.symmetric(horizontal: 18 * scale),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _teacherDeepTeal : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border:
                selected ? null : Border.all(color: const Color(0xFFDDE4E6)),
            boxShadow: selected
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3 * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: selected ? Colors.white : const Color(0xFF737373),
              fontSize: FontSize.small * scale,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherStudyExerciseCard extends StatelessWidget {
  const _TeacherStudyExerciseCard({
    required this.exercise,
    required this.scale,
    required this.onTap,
  });

  final ClassroomExercise exercise;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise.stableId?.toString() ?? '-';
    final dateParts = _teacherStudyDateParts(exercise.endDate);
    final dueDate = _teacherStudyDateLabel(context, exercise.endDate);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            12 * scale,
            10 * scale,
            12 * scale,
            10 * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFE5ECEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 2 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60 * scale,
                    height: 55 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF).withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateParts?.day ?? '--',
                          style: GoogleFonts.andika(
                            color: _teacherBlue,
                            fontSize: FontSize.large * scale,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        if (dateParts != null) ...[
                          SizedBox(height: 2 * scale),
                          Text(
                            context.formatText(
                              AppKeys.teacherStudyMonth,
                              {'month': dateParts.month},
                            ),
                            style: GoogleFonts.andika(
                              color: const Color(0xFF6B7280),
                              fontSize: FontSize.caption * 0.77 * scale,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _teacherExerciseTitle(context, exercise),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: _teacherBlue,
                            fontSize: FontSize.normal * scale,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        Text(
                          context.formatText(
                            AppKeys.teacherAssignmentId,
                            {'id': exerciseId},
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.andika(
                            color: const Color(0xFF7B8494),
                            fontSize: FontSize.caption * scale,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (dueDate != null) ...[
                Divider(
                  height: 16 * scale,
                  color: const Color(0xFFE9EDF0),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/teacher_homework_detail_calendar.svg',
                      width: 15 * scale,
                      height: 15 * scale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF4B5563),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 7 * scale),
                    Expanded(
                      child: Text(
                        context.formatText(
                          AppKeys.teacherStudyDueDate,
                          {'date': dueDate},
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF4B5563),
                          fontSize: FontSize.caption * scale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherStudyExerciseBatch {
  const _TeacherStudyExerciseBatch({
    this.exercises = const <ClassroomExercise>[],
    this.error,
  });

  final List<ClassroomExercise> exercises;
  final String? error;
}

List<ClassroomExercise> _deduplicateTeacherStudyExercises(
  List<ClassroomExercise> exercises,
) {
  final ids = <int>{};
  return exercises.where((exercise) {
    final id = exercise.stableId;
    return id == null || ids.add(id);
  }).toList(growable: false);
}

int _compareTeacherStudyExercises(
  ClassroomExercise first,
  ClassroomExercise second,
) {
  final firstDate = _teacherStudySortDate(first);
  final secondDate = _teacherStudySortDate(second);
  if (firstDate == null && secondDate == null) {
    return (second.stableId ?? 0).compareTo(first.stableId ?? 0);
  }
  if (firstDate == null) {
    return 1;
  }
  if (secondDate == null) {
    return -1;
  }
  return secondDate.compareTo(firstDate);
}

DateTime? _teacherStudySortDate(ClassroomExercise exercise) {
  for (final value in [
    exercise.createDt,
    exercise.startDate,
    exercise.endDate,
  ]) {
    final parsed = DateTime.tryParse(value?.trim() ?? '');
    if (parsed != null) {
      return parsed;
    }
  }
  return null;
}

_TeacherStudyDateParts? _teacherStudyDateParts(String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  return _TeacherStudyDateParts(
    day: _twoDigits(local.day),
    month: _twoDigits(local.month),
  );
}

String? _teacherStudyDateLabel(BuildContext context, String? value) {
  final parsed = DateTime.tryParse(value?.trim() ?? '');
  if (parsed == null) {
    return null;
  }
  final local = parsed.toLocal();
  final day = _twoDigits(local.day);
  final month = _twoDigits(local.month);
  if (Localizations.localeOf(context).languageCode.toLowerCase() == 'en') {
    return '$month/$day/${local.year}';
  }
  return '$day/$month/${local.year}';
}

class _TeacherStudyDateParts {
  const _TeacherStudyDateParts({
    required this.day,
    required this.month,
  });

  final String day;
  final String month;
}
