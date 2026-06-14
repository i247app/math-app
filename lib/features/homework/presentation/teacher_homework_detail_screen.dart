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
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exercise = await _exerciseService.getExerciseDetail(
        exerciseId: widget.exerciseId,
        profileId: widget.profileId,
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
                onRefresh: _loadDetail,
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
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _teacherTeal,
                            ),
                          ),
                        )
                      else if (_error != null)
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

class _TeacherAssignmentInfoCard extends StatelessWidget {
  const _TeacherAssignmentInfoCard({
    required this.exercise,
    required this.visibility,
    required this.onVisibilityChanged,
  });

  final ClassroomExercise? exercise;
  final String? visibility;
  final ValueChanged<String> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/teacher_homework_detail_class.svg',
                    width: 17,
                    height: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _teacherExerciseClassLabel(context, exercise),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.andika(
                        color: const Color(0xFF444650),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 24 / 14,
                      ),
                    ),
                  ),
                  _TeacherAssignmentSwitch(
                    visibility: visibility,
                    onChanged: onVisibilityChanged,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _teacherExerciseTitle(context, exercise),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _teacherBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 36 / 18,
                ),
              ),
              if (_exerciseInfoRows(context, exercise).isNotEmpty) ...[
                const SizedBox(height: 6),
                for (final row in _exerciseInfoRows(context, exercise))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _TeacherAssignmentInfoRow(row),
                  ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 19),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TeacherAssignmentStatDue(exercise)),
                    const SizedBox(width: 30),
                    Expanded(child: _TeacherAssignmentStatQuestions(exercise)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherAssignmentInfoRow extends StatelessWidget {
  const _TeacherAssignmentInfoRow(this.row);

  final _TeacherAssignmentLabeledValue row;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.andika(
          color: const Color(0xFF444650),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 24 / 14,
        ),
        children: [
          TextSpan(
            text: '${row.label}: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: row.value),
        ],
      ),
    );
  }
}

List<_TeacherAssignmentLabeledValue> _exerciseInfoRows(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final rows = <_TeacherAssignmentLabeledValue>[];
  final chapter = exercise?.chapterName?.trim();
  final lesson = exercise?.lessonName?.trim();
  final description = exercise?.description?.trim();

  if (chapter != null && chapter.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentChapterLabel),
        chapter,
      ),
    );
  }
  if (lesson != null && lesson.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentLessonLabel),
        lesson,
      ),
    );
  }
  if (description != null && description.isNotEmpty) {
    rows.add(
      _TeacherAssignmentLabeledValue(
        context.getText(AppKeys.teacherAssignmentDescriptionLabel),
        description,
      ),
    );
  }

  return rows;
}

class _TeacherAssignmentLabeledValue {
  const _TeacherAssignmentLabeledValue(this.label, this.value);

  final String label;
  final String value;
}

String _teacherExerciseClassLabel(
  BuildContext context,
  ClassroomExercise? exercise,
) {
  final classroomId = exercise?.classroomId;
  if (classroomId == null) {
    return '';
  }
  return context.formatText(
    AppKeys.teacherAssignmentId,
    {'id': classroomId},
  );
}

String? _normalizeExerciseVisibility(String? value) {
  final normalized = value?.trim().toUpperCase();
  if (normalized == 'PUBLIC' || normalized == 'PRIVATE') {
    return normalized;
  }
  return null;
}

class _TeacherAssignmentSwitch extends StatelessWidget {
  const _TeacherAssignmentSwitch({
    required this.visibility,
    required this.onChanged,
  });

  final String? visibility;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: visibility == 'PUBLIC',
      activeThumbColor: Colors.white,
      activeTrackColor: _teacherTeal,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE87151),
      onChanged: (value) => onChanged(value ? 'PUBLIC' : 'PRIVATE'),
    );
  }
}

class _TeacherAssignmentStatDue extends StatelessWidget {
  const _TeacherAssignmentStatDue(this.exercise);

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return _TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentDueLabel),
      iconAsset: 'assets/images/teacher_homework_detail_calendar.svg',
      value: _teacherExerciseDueDate(context, exercise),
      valueFontSize: 13,
    );
  }
}

class _TeacherAssignmentStatQuestions extends StatelessWidget {
  const _TeacherAssignmentStatQuestions(this.exercise);

  final ClassroomExercise? exercise;

  @override
  Widget build(BuildContext context) {
    return _TeacherAssignmentStat(
      label: context.getText(AppKeys.teacherAssignmentQuestionCountLabel),
      iconAsset: 'assets/images/teacher_homework_detail_questions.svg',
      value: _teacherExerciseQuestionCount(context, exercise),
      valueFontSize: 16,
    );
  }
}

class _TeacherAssignmentStat extends StatelessWidget {
  const _TeacherAssignmentStat({
    required this.label,
    required this.iconAsset,
    required this.value,
    required this.valueFontSize,
  });

  final String label;
  final String iconAsset;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.andika(
            color: const Color(0xFF444650),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 16 / 12,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 15,
              height: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.andika(
                  color: _teacherInk,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w400,
                  height: 24 / valueFontSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TeacherQuestionCard extends StatelessWidget {
  const _TeacherQuestionCard({
    required this.questionNumber,
    this.question,
  });

  final int questionNumber;
  final ClassroomExerciseQuestion? question;

  @override
  Widget build(BuildContext context) {
    final prompt = question?.displayPrompt ??
        context.getText(AppKeys.teacherAssignmentEquationPrompt);
    final answers = question?.answers ?? const <String>[];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.fromLTRB(21, 6, 21, 21),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFC4C6D2).withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.formatText(
                  AppKeys.teacherAssignmentQuestionNumber,
                  {'number': questionNumber},
                ),
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E6467),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 24 / 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                prompt,
                style: GoogleFonts.andika(
                  color: _teacherInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 24 / 14,
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < answers.length; index++) ...[
                _TeacherAnswerOption(
                  letter: _answerLetter(index),
                  text: answers[index],
                  selected: _isCorrectAnswer(question, answers[index], index),
                ),
                if (index != answers.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _answerLetter(int index) {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (index < 0 || index >= letters.length) {
    return '?';
  }
  return letters[index];
}

bool _isCorrectAnswer(
  ClassroomExerciseQuestion? question,
  String answer,
  int index,
) {
  final correct = question?.correctAnswer?.trim();
  if (correct == null || correct.isEmpty) {
    return false;
  }
  return correct == answer.trim() || correct == _answerLetter(index);
}

class _TeacherAnswerOption extends StatelessWidget {
  const _TeacherAnswerOption({
    required this.letter,
    required this.text,
    this.selected = false,
  });

  final String letter;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final letterBg =
        selected ? const Color(0xFFCDF4F4) : const Color(0xFFFFDBD1);
    final letterColor = selected ? const Color(0xFF1E6467) : _teacherCoral;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF9FFFF) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(0xFF529C9F)
              : const Color(0xFFC4C6D2).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: letterBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              letter,
              style: GoogleFonts.andika(
                color: letterColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: _teacherInk,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                height: 24 / 16,
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/images/teacher_homework_detail_check.svg',
              width: 20,
              height: 20,
            ),
          ],
        ],
      ),
    );
  }
}
