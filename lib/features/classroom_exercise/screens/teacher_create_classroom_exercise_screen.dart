import 'dart:async';

import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/features/profile/models/grade.dart';
import 'package:numi/features/profile/models/program.dart';
import 'package:numi/features/profile/models/school.dart';
import 'package:numi/features/classroom/data/classroom_service.dart';
import 'package:numi/features/classroom/data/classroom_exception.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/profile/data/grade_service.dart';
import 'package:numi/features/profile/data/profile_service.dart';
import 'package:numi/features/profile/data/school_service.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_choice_chip.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_class_summary.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_date_field.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_helpers.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_input.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_label.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_labeled_input.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_option_bottom_sheet.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_publish_switch.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_select_field.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_create/teacher_create_classroom_exercise_submit_button.dart';
import 'package:numi/features/classroom_exercise/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

part 'teacher_create_classroom_exercise/form_actions.dart';
part 'teacher_create_classroom_exercise/data_actions.dart';

class TeacherCreateClassroomExerciseScreen extends StatefulWidget {
  const TeacherCreateClassroomExerciseScreen({
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
  State<TeacherCreateClassroomExerciseScreen> createState() =>
      _TeacherCreateClassroomExerciseScreenState();
}

class _TeacherCreateClassroomExerciseScreenState
    extends State<TeacherCreateClassroomExerciseScreen> {
  static const List<int> _questionCountOptions = <int>[5, 10, 15, 20];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _lessonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final GuardedExitController<bool> _exitController =
      GuardedExitController<bool>();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? context.read<ClassroomExerciseService>();
  late final ClassroomService _classroomService =
      widget._classroomService ?? context.read<ClassroomService>();
  late final GradeService _gradeService =
      widget._gradeService ?? context.read<GradeService>();
  late final ProfileService _profileService =
      widget._profileService ?? context.read<ProfileService>();
  late final SchoolService _schoolService =
      widget._schoolService ?? context.read<SchoolService>();
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
  bool _isDraftDirty = false;
  String? _titleErrorText;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_handleTitleChanged);
    _chapterController.addListener(_markDraftDirty);
    _lessonController.addListener(_markDraftDirty);
    _descriptionController.addListener(_markDraftDirty);
    _loadClassrooms();
    _loadLookupOptions();
  }

  @override
  void dispose() {
    _titleController.removeListener(_handleTitleChanged);
    _chapterController.removeListener(_markDraftDirty);
    _lessonController.removeListener(_markDraftDirty);
    _descriptionController.removeListener(_markDraftDirty);
    _titleController.dispose();
    _chapterController.dispose();
    _lessonController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;

    final screen = GestureDetector(
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
                onBack: _exitController.requestExit,
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
                          CreateClassroomExerciseSelectField(
                            valueText: createClassroomExerciseClassName(
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
                            child: CreateClassroomExerciseClassSummary(
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
                            child: CreateClassroomExerciseInput(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              errorText: _titleErrorText,
                              hintKey: teacherExerciseCopy(
                                widget.purpose,
                              ).titleHintKey,
                              height: 62,
                              radius: 10,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 13),
                            child: CreateClassroomExerciseLabel(
                              context.getText(
                                AppKeys.teacherAssignmentProgramLabel,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 9),
                            child: CreateClassroomExerciseSelectField(
                              valueKey: AppKeys.teacherAssignmentProgramLabel,
                              valueText: selectedClassroomExerciseProgramName(
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
                            child: CreateClassroomExerciseLabel(
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
                                    child: CreateClassroomExerciseChoiceChip(
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
                            child: CreateClassroomExerciseLabel(
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
                                  child: CreateClassroomExerciseDateField(
                                    hintKey:
                                        AppKeys.teacherAssignmentStartDateHint,
                                    valueText:
                                        formatCreateClassroomExerciseDate(
                                          _startDate,
                                        ),
                                    onTap: () => _openDatePicker(isStart: true),
                                  ),
                                ),
                                Expanded(
                                  child: CreateClassroomExerciseDateField(
                                    hintKey:
                                        AppKeys.teacherAssignmentEndDateHint,
                                    valueText:
                                        formatCreateClassroomExerciseDate(
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
                                  child: CreateClassroomExerciseLabeledInput(
                                    labelKey:
                                        AppKeys.teacherAssignmentChapterLabel,
                                    controller: _chapterController,
                                  ),
                                ),
                                Expanded(
                                  child: CreateClassroomExerciseLabeledInput(
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
                            child: CreateClassroomExerciseInput(
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
                            child: CreateClassroomExercisePublishSwitch(
                              isPublished: _visibility == 'PUBLIC',
                              onChanged: (isPublished) {
                                setState(() {
                                  _visibility = isPublished
                                      ? 'PUBLIC'
                                      : 'PRIVATE';
                                  _isDraftDirty = true;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Center(
                              child: CreateClassroomExerciseSubmitButton(
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

    return GuardedExitScope<bool>(
      controller: _exitController,
      shouldConfirm: _isDraftDirty,
      isExitBlocked: _isSubmitting,
      confirmExit: showUnsavedChangesExitDialog,
      child: screen,
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
