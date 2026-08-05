import 'dart:async';
import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_choice_chip.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_class_summary.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_date_field.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_helpers.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_input.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_label.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_labeled_input.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_option_bottom_sheet.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_publish_switch.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_select_field.dart';
import 'package:numi/features/homework/widgets/teacher_create/teacher_create_homework_submit_button.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_copy.dart';

class TeacherCreateHomeworkScreen extends StatefulWidget {
  const TeacherCreateHomeworkScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.userId,
    this.initialClassroom,
    this.purpose = classroomExercisePurposeHomework,
    ClassroomExerciseService? exerciseService,
    ClassroomService? classroomService,
    GradeService? gradeService,
    ProfileService? profileService,
    SchoolService? schoolService,
  }) : _exerciseService = exerciseService,
       _classroomService = classroomService,
       _gradeService = gradeService,
       _profileService = profileService,
       _schoolService = schoolService;

  final int classroomId;
  final int profileId;
  final int? userId;
  final ClassroomModel? initialClassroom;
  final String purpose;
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
  static const List<int> _questionCountOptions = <int>[5, 10, 15, 20];

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
  int _selectedQuestionCount = _questionCountOptions.first;
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
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        numQuestions: _selectedQuestionCount,
        chapterName: trimOrDefault(
          _chapterController.text,
          context.readText(AppKeys.teacherAssignmentDefaultChapter),
        ),
        lessonName: trimOrDefault(
          _lessonController.text,
          context.readText(AppKeys.teacherAssignmentDefaultLesson),
        ),
        visibility: _visibility,
        startDate: exerciseApiDate(_startDate!),
        endDate: exerciseApiDate(_endDate!),
        purpose: widget.purpose,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ClassroomExerciseException catch (error) {
      if (!mounted) {
        return;
      }
      _showError(
        error.message.trim().isEmpty
            ? context.readText(
                teacherExerciseCopy(widget.purpose).createFailedKey,
              )
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

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  bool _validateCreateHomeworkForm() {
    final now = DateTime.now();
    if (_selectedProgramId == null) {
      _showError(context.readText(AppKeys.teacherAssignmentProgramRequired));
      return false;
    }
    if (_startDate == null) {
      _showError(context.readText(AppKeys.teacherAssignmentStartDateRequired));
      return false;
    }
    if (_endDate == null) {
      _showError(context.readText(AppKeys.teacherAssignmentEndDateRequired));
      return false;
    }
    if (!_startDate!.isAfter(now) || !_endDate!.isAfter(now)) {
      _showError(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return false;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
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
        _classrooms = mergeSelectedClassroom(classrooms, _selectedClassroom);
        _selectedClassroom =
            matchingClassroom(_classrooms, _selectedClassroomId) ??
            _selectedClassroom;
        _selectedProgramId = validProgramIdForClassroom(
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
      _showError(error.message);
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
        _selectedProgramId = validProgramIdForClassroom(
          classroom,
          _selectedProgramId,
          _programs,
        );
      });
    } on ClassroomException catch (error) {
      if (mounted) {
        _showError(error.message);
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
        _selectedProgramId = validProgramIdForClassroom(
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
    _dismissKeyboard();
    if (_classrooms.isEmpty) {
      await _loadClassrooms();
    }
    if (!mounted || _classrooms.isEmpty) {
      if (mounted) {
        _showError(context.readText(AppKeys.teacherNoOptions));
      }
      return;
    }

    final selected = await showModalBottomSheet<ClassroomModel>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return CreateHomeworkOptionBottomSheet<ClassroomModel>(
          options: _classrooms,
          titleKey: AppKeys.teacherAssignmentSelectClass,
          isSelected: (classroom) => classroom.stableId == _selectedClassroomId,
          titleBuilder: createHomeworkClassName,
          subtitleBuilder: createHomeworkStudentCount,
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
    _dismissKeyboard();
    final options = programOptionsForClassroom(
      context,
      _selectedClassroom,
      _programs,
    );
    if (options.isEmpty) {
      _showError(context.readText(AppKeys.teacherNoOptions));
      return;
    }

    final selected = await showModalBottomSheet<ClassroomProgramOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottomInset = MediaQuery.paddingOf(context).bottom;
        return CreateHomeworkOptionBottomSheet<ClassroomProgramOption>(
          options: options,
          titleKey: AppKeys.teacherAssignmentProgramLabel,
          isSelected: (option) => option.id == _selectedProgramId,
          titleBuilder: (_, option) => option.label,
          bottomInset: bottomInset,
        );
      },
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() => _selectedProgramId = selected.id);
  }

  void _selectQuestionCount(int count) {
    HapticFeedback.selectionClick();
    setState(() => _selectedQuestionCount = count);
  }

  Future<void> _openDatePicker({required bool isStart}) async {
    _dismissKeyboard();
    final now = DateTime.now();
    final minimum = now.add(const Duration(minutes: 1));
    final currentValue = isStart ? _startDate : _endDate;
    final endMinimum = _startDate?.add(const Duration(minutes: 1));
    final baseInitial =
        currentValue ??
        (isStart
            ? minimum.add(const Duration(hours: 1))
            : endMinimum ?? minimum.add(const Duration(days: 1)));
    final initialDateTime = baseInitial.isAfter(minimum)
        ? baseInitial
        : minimum;
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
      _showError(context.readText(AppKeys.teacherAssignmentFutureDateRequired));
      return;
    }
    if (isStart && _endDate != null && !selected.isBefore(_endDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
      return;
    }
    if (!isStart && _startDate != null && !selected.isAfter(_startDate!)) {
      _showError(context.readText(AppKeys.teacherAssignmentEndAfterStart));
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

  void _showError(String message) {
    context.showErrorDialog(message);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: colors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppScreenAppBar(
                backIconAsset: 'assets/icons/teacher-class-back.svg',
                title: context.getText(
                  teacherExerciseCopy(widget.purpose).createTitleKey,
                ),
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                          CreateHomeworkSelectField(
                            valueText: createHomeworkClassName(
                              context,
                              _selectedClassroom,
                            ),
                            isLoading: _isLoadingClassrooms,
                            radius: 16,
                            fontSize: FontSize.normal,
                            fontWeight: FontWeight.w500,
                            textOpacity: 1,
                            iconAsset:
                                'assets/icons/teacher-homework-dropdown.svg',
                            iconWidth: 12,
                            iconHeight: 8,
                            onTap: _openClassSelector,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: CreateHomeworkClassSummary(
                              classroom: _selectedClassroom,
                              grades: _grades,
                              programs: _programs,
                              schools: _schools,
                              isLoading:
                                  _isLoadingClassrooms ||
                                  _isLoadingSelectedClassroom ||
                                  _isLoadingLookups,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 22),
                            child: CreateHomeworkInput(
                              controller: _titleController,
                              hintKey: teacherExerciseCopy(
                                widget.purpose,
                              ).titleHintKey,
                              height: 62,
                              radius: 10,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13),
                            child: CreateHomeworkLabel(
                              context.getText(
                                AppKeys.teacherAssignmentProgramLabel,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: CreateHomeworkSelectField(
                              valueKey: AppKeys.teacherAssignmentProgramLabel,
                              valueText: selectedHomeworkProgramName(
                                context,
                                _programs,
                                _selectedProgramId,
                              ),
                              radius: 12,
                              borderColor: const Color(0xFFC4C6D2),
                              borderWidth: 1,
                              iconAsset:
                                  'assets/icons/teacher-homework-dropdown.svg',
                              iconWidth: 12,
                              iconHeight: 8,
                              onTap: _openProgramSelector,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: CreateHomeworkLabel(
                              context.getText(
                                AppKeys.teacherAssignmentQuestionCountLabel,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: Row(
                              spacing: 8,
                              children: [
                                for (final count in _questionCountOptions)
                                  Expanded(
                                    child: CreateHomeworkChoiceChip(
                                      label: '$count',
                                      selected: count == _selectedQuestionCount,
                                      onTap: () => _selectQuestionCount(count),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: CreateHomeworkLabel(
                              context.getText(
                                AppKeys.teacherAssignmentDeadline,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: CreateHomeworkDateField(
                                    hintKey:
                                        AppKeys.teacherAssignmentStartDateHint,
                                    valueText: formatCreateHomeworkDate(
                                      _startDate,
                                    ),
                                    onTap: () => _openDatePicker(isStart: true),
                                  ),
                                ),
                                Expanded(
                                  child: CreateHomeworkDateField(
                                    hintKey:
                                        AppKeys.teacherAssignmentEndDateHint,
                                    valueText: formatCreateHomeworkDate(
                                      _endDate,
                                    ),
                                    onTap: () =>
                                        _openDatePicker(isStart: false),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 14,
                              children: [
                                Expanded(
                                  child: CreateHomeworkLabeledInput(
                                    labelKey:
                                        AppKeys.teacherAssignmentChapterLabel,
                                    controller: _chapterController,
                                  ),
                                ),
                                Expanded(
                                  child: CreateHomeworkLabeledInput(
                                    labelKey:
                                        AppKeys.teacherAssignmentLessonLabel,
                                    controller: _lessonController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 17),
                            child: CreateHomeworkInput(
                              controller: _descriptionController,
                              hintKey: teacherExerciseCopy(
                                widget.purpose,
                              ).descriptionHintKey,
                              height: 167,
                              maxLines: 6,
                              textAlignVertical: TextAlignVertical.top,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: CreateHomeworkPublishSwitch(
                              isPublished: _visibility == 'PUBLIC',
                              onChanged: (isPublished) {
                                setState(
                                  () => _visibility = isPublished
                                      ? 'PUBLIC'
                                      : 'PRIVATE',
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Center(
                              child: CreateHomeworkSubmitButton(
                                isLoading: _isSubmitting,
                                onTap: _submit,
                              ),
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
      ),
    );
  }
}
