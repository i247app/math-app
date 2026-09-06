import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom_exercise/data/student_classroom_exercise_cache.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/screens/student_classroom_exercise_attempt_screen.dart';
import 'package:numi/features/classroom_exercise/helpers/student_classroom_exercise_open_guard.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_assignment_card.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_filter.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_filter_tabs.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_helpers.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_message.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_search_field.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom_exercise/widgets/student_list/student_classroom_exercise_top_bar.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';

class StudentClassroomExerciseScreen extends StatefulWidget {
  const StudentClassroomExerciseScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentClassroomExerciseScreen> createState() =>
      _StudentClassroomExerciseScreenState();
}

class _StudentClassroomExerciseScreenState
    extends State<StudentClassroomExerciseScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? context.read<ClassroomExerciseService>();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];
  StudentClassroomExerciseFilter _activeFilter =
      StudentClassroomExerciseFilter.notSubmitted;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 420), () {
      _loadExercises(search: value);
    });
  }

  void _setFilter(StudentClassroomExerciseFilter filter) {
    if (_activeFilter == filter) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _activeFilter = filter);
    _loadExercises(search: _searchController.text);
  }

  Future<void> _loadExercises({
    String? search,
    bool forceRefresh = false,
  }) async {
    final normalizedSearch = search?.trim() ?? _searchController.text.trim();
    final requestSubmissionStatus = _activeFilter.submissionStatus;
    final requestSearch = normalizedSearch.isEmpty ? null : normalizedSearch;
    if (!forceRefresh) {
      final cachedExercises = StudentClassroomExerciseCache.peekList(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        search: requestSearch,
        visibility: 'PUBLIC',
        submissionStatus: requestSubmissionStatus,
      );
      if (cachedExercises != null) {
        setState(() {
          _exercises = cachedExercises;
          _isLoading = true;
          _error = null;
        });
        await _loadExercises(search: normalizedSearch, forceRefresh: true);
        return;
      }
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final exercises = await StudentClassroomExerciseCache.loadList(
        service: _exerciseService,
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        search: requestSearch,
        visibility: 'PUBLIC',
        submissionStatus: requestSubmissionStatus,
        forceRefresh: forceRefresh,
      );
      if (!mounted ||
          _searchController.text.trim() != normalizedSearch ||
          _activeFilter.submissionStatus != requestSubmissionStatus) {
        return;
      }
      setState(() => _exercises = exercises);
    } on ClassroomExerciseException catch (error) {
      if (!mounted ||
          _searchController.text.trim() != normalizedSearch ||
          _activeFilter.submissionStatus != requestSubmissionStatus) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted &&
          _searchController.text.trim() == normalizedSearch &&
          _activeFilter.submissionStatus == requestSubmissionStatus) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openExercise(ClassroomExercise exercise) async {
    if (studentClassroomExerciseIsSubmitted(exercise)) {
      context.showErrorDialog(
        context.getText(AppKeys.studentClassroomExerciseAlreadySubmitted),
      );
      return;
    }

    if (showStudentClassroomExerciseNotOpenDialogIfNeeded(context, exercise)) {
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      context.showErrorDialog(
        context.getText(AppKeys.studentClassroomExerciseMissingExercise),
      );
      return;
    }

    StudentClassroomExerciseCache.seedDetail(
      profileId: widget.profileId,
      exercise: exercise,
    );
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => StudentClassroomExerciseAttemptScreen(
          exerciseId: exerciseId,
          profileId: widget.profileId,
          initialExercise: exercise,
          exerciseService: _exerciseService,
        ),
      ),
    );
    if (submitted == true) {
      _loadExercises(search: _searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.themeColors;
    final visibleExercises = filteredStudentClassroomExerciseExercises(
      _exercises,
      _activeFilter,
    );
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StudentClassroomExerciseTopBar(
              title: context.getText(AppKeys.studentClassroomExercise),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  28,
                  20,
                  MediaQuery.paddingOf(context).bottom + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StudentClassroomExerciseSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) => _loadExercises(search: value),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: StudentClassroomExerciseFilterTabs(
                        activeFilter: _activeFilter,
                        onFilterSelected: _setFilter,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: _isLoading && _exercises.isEmpty
                          ? StudentClassroomExerciseMessage(
                              message: context.getText(AppKeys.loading),
                            )
                          : _error != null && _exercises.isEmpty
                          ? StudentClassroomExerciseMessage(message: _error!)
                          : _exercises.isEmpty || visibleExercises.isEmpty
                          ? StudentClassroomExerciseMessage(
                              message: context.getText(
                                AppKeys.studentNoClassroomExerciseMessage,
                              ),
                            )
                          : Column(
                              spacing: 14,
                              children: [
                                for (final exercise in visibleExercises)
                                  StudentClassroomExerciseAssignmentCard(
                                    exercise: exercise,
                                    onTap: () => _openExercise(exercise),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
