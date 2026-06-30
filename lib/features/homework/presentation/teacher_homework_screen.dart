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

  Future<void> _loadExercises({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedExercises = _TeacherHomeworkCache.peekList(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        purpose: widget.purpose,
      );
      if (cachedExercises != null) {
        setState(() {
          _exercises = cachedExercises;
          _isLoading = true;
          _error = null;
        });
        await _loadExercises(forceRefresh: true);
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercises = await _TeacherHomeworkCache.loadList(
        service: _exerciseService,
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        purpose: widget.purpose,
        forceRefresh: forceRefresh,
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
      _TeacherHomeworkCache.invalidateList(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        purpose: widget.purpose,
      );
      await _loadExercises(forceRefresh: true);
    }
  }

  void _openExerciseDetail(ClassroomExercise exercise) {
    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      _showTeacherHomeworkSoon(context);
      return;
    }
    _TeacherHomeworkCache.seedDetail(
      profileId: widget.profileId,
      exercise: exercise,
    );

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
                onRefresh: () => _loadExercises(forceRefresh: true),
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
                        for (
                          var index = 0;
                          index < _exercises.length;
                          index++
                        ) ...[
                          _TeacherAssignmentCard(
                            exercise: _exercises[index],
                            onTap: () => _openExerciseDetail(_exercises[index]),
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
