import 'dart:async';

import 'package:numi/core/theme/font_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/domain/models/grade.dart';
import 'package:numi/features/profile/domain/models/program.dart';
import 'package:numi/features/profile/domain/models/school.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/application/errors/classroom_exception.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/profile/application/contracts/grade_service.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/profile/application/contracts/school_service.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/homework/application/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_choice_chip.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_class_summary.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_date_field.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_helpers.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_input.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_label.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_labeled_input.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_option_bottom_sheet.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_publish_switch.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_select_field.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_create/teacher_create_homework_submit_button.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/shared/widgets/exit_confirmation_dialog.dart';
import 'package:numi/shared/widgets/guarded_exit_scope.dart';

part 'teacher_create_homework/form_actions.dart';
part 'teacher_create_homework/data_actions.dart';

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
