import 'package:numi_flutter/core/theme/app_colors.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/core/network/grade_models.dart';
import 'package:numi_flutter/core/network/program_models.dart';
import 'package:numi_flutter/core/network/school_models.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/presentation/teacher_classroom_screens.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';
import 'package:numi_flutter/features/profile/grade_api.dart';
import 'package:numi_flutter/features/profile/profile_api.dart';
import 'package:numi_flutter/features/profile/school_api.dart';

part '../cache/teacher_homework_cache.dart';
part 'teacher_homework_detail_screen.dart';
part 'teacher_create_homework_screen.dart';
part '../widgets/teacher_list/teacher_homework_add_button.dart';
part '../widgets/teacher_list/teacher_homework_search_field.dart';
part '../widgets/teacher_list/teacher_homework_section_header.dart';
part '../widgets/teacher_list/teacher_exercise_copy.dart';
part '../widgets/teacher_list/teacher_assignment_card.dart';
part '../widgets/teacher_list/teacher_empty_assignments_panel.dart';
part '../widgets/teacher_list/teacher_exercise_helpers.dart';
part '../widgets/teacher_detail/teacher_assignment_info_card.dart';
part '../widgets/teacher_detail/teacher_assignment_info_row.dart';
part '../widgets/teacher_detail/teacher_assignment_labeled_value.dart';
part '../widgets/teacher_detail/teacher_assignment_switch.dart';
part '../widgets/teacher_detail/teacher_assignment_stat_due.dart';
part '../widgets/teacher_detail/teacher_assignment_stat_questions.dart';
part '../widgets/teacher_detail/teacher_assignment_stat.dart';
part '../widgets/teacher_detail/teacher_question_card.dart';
part '../widgets/teacher_detail/teacher_answer_option.dart';
part '../widgets/teacher_detail/teacher_assignment_detail_helpers.dart';
part '../widgets/teacher_create/teacher_create_homework_class_selector.dart';
part '../widgets/teacher_create/teacher_create_homework_class_bottom_sheet.dart';
part '../widgets/teacher_create/teacher_create_homework_program_bottom_sheet.dart';
part '../widgets/teacher_create/teacher_create_homework_class_summary.dart';
part '../widgets/teacher_create/teacher_create_homework_class_meta.dart';
part '../widgets/teacher_create/teacher_create_homework_labeled_input.dart';
part '../widgets/teacher_create/teacher_create_homework_label.dart';
part '../widgets/teacher_create/teacher_create_homework_input.dart';
part '../widgets/teacher_create/teacher_create_homework_publish_switch.dart';
part '../widgets/teacher_create/teacher_create_homework_select_field.dart';
part '../widgets/teacher_create/teacher_create_homework_date_field.dart';
part '../widgets/teacher_create/teacher_create_homework_submit_button.dart';
part '../widgets/teacher_create/teacher_create_homework_helpers.dart';

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
                teacherExerciseCopy(widget.purpose).listLoadFailedKey,
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
      showTeacherHomeworkSoon(context);
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
            TeacherScreenAppBar(
              title: context.getText(
                teacherExerciseCopy(widget.purpose).titleKey,
              ),
              scale: 1,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.teal520,
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
                        child: TeacherHomeworkAddButton(
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
                              color: AppColors.teal520,
                            ),
                          ),
                        )
                      else if (_error != null && _exercises.isEmpty)
                        TeacherErrorPanel(
                          scale: 1,
                          message: _error!,
                          onRetry: _loadExercises,
                        )
                      else if (_exercises.isEmpty)
                        TeacherEmptyAssignmentsPanel(
                          message: context.getText(
                            teacherExerciseCopy(widget.purpose).emptyKey,
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
                          const TeacherBackgroundRefreshLabel(scale: 1),
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
