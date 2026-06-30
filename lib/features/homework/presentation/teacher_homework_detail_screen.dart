part of '../../classroom/presentation/teacher_classroom_screens.dart';

class TeacherHomeworkDetailScreen extends StatefulWidget {
  const TeacherHomeworkDetailScreen({
    super.key,
    required this.exerciseId,
    required this.profileId,
    this.initialExercise,
    this.purpose = classroomExercisePurposeHomework,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int exerciseId;
  final int profileId;
  final ClassroomExercise? initialExercise;
  final String purpose;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherHomeworkDetailScreen> createState() =>
      _TeacherHomeworkDetailScreenState();
}

class _TeacherHomeworkDetailScreenState
    extends State<TeacherHomeworkDetailScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  ClassroomExercise? _exercise;
  String? _savedVisibility;
  String? _editingVisibility;

  String get _effectivePurpose => _exercise?.purpose?.trim().isNotEmpty == true
      ? _exercise!.purpose!.trim()
      : widget.initialExercise?.purpose?.trim().isNotEmpty == true
      ? widget.initialExercise!.purpose!.trim()
      : widget.purpose;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
    final visibility = _normalizeExerciseVisibility(_exercise?.visibility);
    _savedVisibility = visibility;
    _editingVisibility = visibility;
    _loadDetail();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercise = await _TeacherHomeworkCache.loadDetail(
        service: _exerciseService,
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      final visibility = _normalizeExerciseVisibility(exercise?.visibility);
      setState(() {
        _exercise = exercise ?? _exercise;
        _savedVisibility = visibility;
        _editingVisibility = visibility;
      });
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message.trim().isEmpty
            ? context.readText(
                _teacherExerciseCopy(_effectivePurpose).detailLoadFailedKey,
              )
            : error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _hasVisibilityChange =>
      _editingVisibility != null && _editingVisibility != _savedVisibility;

  Future<void> _saveVisibility() async {
    final visibility = _editingVisibility;
    final exerciseId = _exercise?.stableId ?? widget.exerciseId;
    if (_isSaving || visibility == null || !_hasVisibilityChange) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final updated = await _exerciseService.updateExerciseVisibility(
        profileId: widget.profileId,
        classroomExerciseId: exerciseId,
        visibility: visibility,
        purpose: _effectivePurpose,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _exercise = updated ?? _exercise;
        _savedVisibility =
            _normalizeExerciseVisibility(updated?.visibility) ?? visibility;
        _editingVisibility = _savedVisibility;
      });
      if (updated != null) {
        _TeacherHomeworkCache.replaceDetail(
          profileId: widget.profileId,
          exercise: updated,
        );
      }
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.message.trim().isEmpty
                  ? context.readText(
                      _teacherExerciseCopy(_effectivePurpose).createFailedKey,
                    )
                  : error.message,
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1400),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;
    final questions =
        exercise?.questions ?? const <ClassroomExerciseQuestion>[];
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFFF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TeacherScreenAppBar(
              title: context.getText(
                _teacherExerciseCopy(_effectivePurpose).titleKey,
              ),
              scale: 1,
              onBack: () => Navigator.of(context).maybePop(),
              action: _hasVisibilityChange
                  ? TextButton(
                      onPressed: _isSaving ? null : _saveVisibility,
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _teacherTeal,
                              ),
                            )
                          : Text(
                              context.getText(AppKeys.save),
                              style: GoogleFonts.andika(
                                color: _teacherTeal,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    )
                  : null,
            ),
            Expanded(
              child: RefreshIndicator(
                color: _teacherTeal,
                onRefresh: () => _loadDetail(forceRefresh: true),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    17,
                    14,
                    18,
                    MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading && exercise == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _teacherTeal,
                            ),
                          ),
                        )
                      else if (_error != null && exercise == null)
                        _TeacherErrorPanel(
                          scale: 1,
                          message: _error!,
                          onRetry: _loadDetail,
                        )
                      else ...[
                        _TeacherAssignmentInfoCard(
                          exercise: exercise,
                          visibility: _editingVisibility,
                          onVisibilityChanged: (visibility) {
                            setState(() => _editingVisibility = visibility);
                          },
                        ),
                        const SizedBox(height: 13),
                        Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: Text(
                            context.getText(
                              AppKeys.teacherAssignmentQuestionContent,
                            ),
                            style: GoogleFonts.andika(
                              color: _teacherBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 32 / 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var index = 0; index < questions.length; index++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: index == questions.length - 1 ? 0 : 15,
                            ),
                            child: _TeacherQuestionCard(
                              questionNumber:
                                  questions[index].questionNumber ?? index + 1,
                              question: questions[index],
                            ),
                          ),
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
