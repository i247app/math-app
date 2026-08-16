import 'dart:async';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/data/cache/teacher_homework_cache.dart';
import 'package:numi/features/homework/presentation/screens/teacher_create_homework_screen.dart';
import 'package:numi/features/homework/presentation/screens/teacher_homework_detail_screen.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_assignment_card.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_empty_assignments_panel.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_exercise_helpers.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_homework_add_button.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_homework_search_field.dart';
import 'package:numi/features/homework/widgets/teacher_list/teacher_homework_section_header.dart';

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
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    setState(() {});
  }

  List<ClassroomExercise> get _visibleExercises {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _exercises;
    }

    return _exercises
        .where((exercise) {
          final searchable = <String>[
            exercise.title ?? '',
            exercise.description ?? '',
            exercise.shortText ?? '',
            exercise.chapterName ?? '',
            exercise.lessonName ?? '',
            exercise.status ?? '',
            exercise.visibility ?? '',
            exercise.stableId?.toString() ?? '',
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        })
        .toList(growable: false);
  }

  Future<void> _loadExercises({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedExercises = TeacherHomeworkCache.peekList(
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
      final exercises = await TeacherHomeworkCache.loadList(
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
      TeacherHomeworkCache.invalidateList(
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
    TeacherHomeworkCache.seedDetail(
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
    final colors = context.themeColors;
    final visibleExercises = _visibleExercises;

    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenAppBar(
              backIconAsset: 'assets/icons/teacher-class-back.svg',
              title: context.getText(
                teacherExerciseCopy(widget.purpose).titleKey,
              ),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.brandStrong,
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
                      Padding(
                        padding: const EdgeInsets.only(top: 33),
                        child: TeacherHomeworkSearchField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: TeacherHomeworkSectionHeader(
                          purpose: widget.purpose,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 17),
                        child: _isLoading && _exercises.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: colors.brandStrong,
                                  ),
                                ),
                              )
                            : _error != null && _exercises.isEmpty
                            ? AppRetryPanel(
                                message: _error!,
                                onRetry: _loadExercises,
                              )
                            : _exercises.isEmpty
                            ? TeacherEmptyAssignmentsPanel(
                                message: context.getText(
                                  teacherExerciseCopy(widget.purpose).emptyKey,
                                ),
                              )
                            : visibleExercises.isEmpty
                            ? TeacherEmptyAssignmentsPanel(
                                message: context.getText(
                                  AppKeys.teacherStudyNoResults,
                                ),
                              )
                            : Column(
                                spacing: 10,
                                children: [
                                  for (final exercise in visibleExercises)
                                    TeacherAssignmentCard(
                                      exercise: exercise,
                                      onTap: () =>
                                          _openExerciseDetail(exercise),
                                    ),
                                ],
                              ),
                      ),
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
