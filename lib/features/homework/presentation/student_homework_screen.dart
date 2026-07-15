import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/features/homework/data/cache/student_homework_cache.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/homework/presentation/student_homework_attempt_screen.dart';
import 'package:numi/features/homework/helpers/student_homework_open_guard.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_assignment_card.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_filter.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_filter_tabs.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_helpers.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_message.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_search_field.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/homework/widgets/student_list/student_homework_top_bar.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];
  StudentHomeworkFilter _activeFilter = StudentHomeworkFilter.notSubmitted;

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

  void _setFilter(StudentHomeworkFilter filter) {
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
      final cachedExercises = StudentHomeworkCache.peekList(
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
      final exercises = await StudentHomeworkCache.loadList(
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
    if (studentHomeworkIsSubmitted(exercise)) {
      context.showErrorDialog(
        context.getText(AppKeys.studentHomeworkAlreadySubmitted),
      );
      return;
    }

    if (showStudentHomeworkNotOpenDialogIfNeeded(context, exercise)) {
      return;
    }

    final exerciseId = exercise.stableId;
    if (exerciseId == null) {
      context.showErrorDialog(
        context.getText(AppKeys.studentHomeworkMissingExercise),
      );
      return;
    }

    StudentHomeworkCache.seedDetail(
      profileId: widget.profileId,
      exercise: exercise,
    );
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => StudentHomeworkAttemptScreen(
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
    final visibleExercises = filteredStudentHomeworkExercises(
      _exercises,
      _activeFilter,
    );
    return Scaffold(
      backgroundColor: colors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StudentHomeworkTopBar(
              title: context.getText(AppKeys.studentHomework),
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
                    StudentHomeworkSearchField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) => _loadExercises(search: value),
                    ),
                    const SizedBox(height: 17),
                    StudentHomeworkFilterTabs(
                      activeFilter: _activeFilter,
                      onFilterSelected: _setFilter,
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading && _exercises.isEmpty)
                      StudentHomeworkMessage(
                        message: context.getText(AppKeys.loading),
                      )
                    else if (_error != null && _exercises.isEmpty)
                      StudentHomeworkMessage(message: _error!)
                    else if (_exercises.isEmpty)
                      StudentHomeworkMessage(
                        message: context.getText(
                          AppKeys.studentNoHomeworkMessage,
                        ),
                      )
                    else if (visibleExercises.isEmpty)
                      StudentHomeworkMessage(
                        message: context.getText(
                          AppKeys.studentNoHomeworkMessage,
                        ),
                      )
                    else ...[
                      for (
                        var index = 0;
                        index < visibleExercises.length;
                        index++
                      )
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index == visibleExercises.length - 1
                                ? 0
                                : 14,
                          ),
                          child: StudentHomeworkAssignmentCard(
                            exercise: visibleExercises[index],
                            onTap: () => _openExercise(visibleExercises[index]),
                          ),
                        ),
                    ],
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
