import 'package:numi/core/theme/app_colors.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/homework/domain/models/classroom_exercise.dart';
import 'package:numi/features/classroom/domain/models/classroom.dart';
import 'package:numi/features/profile/domain/models/profile.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/classroom/application/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/application/controllers/classroom_state.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/features/classroom/presentation/widgets/teacher_tab/teacher_classroom_add_button.dart';
import 'package:numi/shared/constants/app_visual_constants.dart';
import 'package:numi/shared/layouts/page_header.dart';
import 'package:numi/features/homework/application/contracts/classroom_exercise_service.dart';
import 'package:numi/features/homework/presentation/screens/teacher_create_homework_screen.dart';
import 'package:numi/features/homework/presentation/screens/teacher_homework_detail_screen.dart';
import 'package:numi/shared/widgets/teacher_empty_assignments_panel.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_list/teacher_exercise_copy.dart';
import 'package:numi/features/homework/application/read_models/teacher_exercise_read_model.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/features/homework/application/errors/classroom_exercise_exception.dart';
import 'package:numi/features/homework/presentation/helpers/teacher_study_helpers.dart';
import 'package:numi/features/homework/application/read_models/teacher_study_exercise_batch.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_class_filters.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_exercise_card.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_loading_indicator.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_load_more_button.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_purpose_filters.dart';
import 'package:numi/features/homework/presentation/widgets/teacher_study/teacher_study_search_field.dart';

part 'teacher_study/data_actions.dart';
part 'teacher_study/navigation_actions.dart';

class TeacherStudyTab extends StatefulWidget {
  const TeacherStudyTab({
    super.key,
    required this.user,
    required this.activeProfile,
    required this.bottomPadding,
    ClassroomService? classroomService,
    ClassroomExerciseService? exerciseService,
    this.activeRefreshTick = 0,
    this.isActive = true,
  }) : _classroomService = classroomService,
       _exerciseService = exerciseService;

  final LoginUser? user;
  final StudentProfile? activeProfile;
  final double bottomPadding;
  final int activeRefreshTick;
  final bool isActive;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<TeacherStudyTab> createState() => _TeacherStudyTabState();
}

class _TeacherStudyTabState extends State<TeacherStudyTab> {
  static const int _exercisePageSize = 10;

  late final ClassroomService _classroomService =
      widget._classroomService ?? context.read<ClassroomService>();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? context.read<ClassroomExerciseService>();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;
  int _exerciseRequestId = 0;
  int? _loadedProfileId;
  int? _selectedClassroomId;
  String _selectedPurpose = classroomExercisePurposeHomework;
  bool _isLoadingExercises = false;
  bool _hasCompletedInitialLoad = false;
  String? _error;
  List<ClassroomExercise> _exercises = const <ClassroomExercise>[];
  int _visibleExerciseCount = _exercisePageSize;

  ClassroomCollectionState get _classroomCollection {
    final profileId = profileStableId(widget.activeProfile);
    if (profileId == null || profileId <= 0) {
      return const ClassroomCollectionState(profileId: 0);
    }
    return context.read<ClassroomCubit>().owned(profileId);
  }

  List<ClassroomModel> get _classrooms => _classroomCollection.classrooms;

  bool get _isLoadingClassrooms => _classroomCollection.isLoading;

  String? get _displayError => _classroomCollection.errorMessage ?? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      _loadClassrooms();
    }
  }

  @override
  void didUpdateWidget(covariant TeacherStudyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _loadClassrooms();
      return;
    }
    if (!widget.isActive) {
      return;
    }
    final profileId = profileStableId(widget.activeProfile);
    if (profileId != _loadedProfileId) {
      _selectedClassroomId = null;
      _loadClassrooms();
    } else if (oldWidget.activeRefreshTick != widget.activeRefreshTick) {
      _loadClassrooms(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileId = profileStableId(widget.activeProfile);
    if (profileId != null && profileId > 0) {
      context.select<ClassroomCubit, ClassroomCollectionState>(
        (cubit) => cubit.owned(profileId),
      );
    }
    final visibleExercises = _exercises
        .take(_visibleExerciseCount)
        .toList(growable: false);
    final remainingExerciseCount = _exercises.length - visibleExercises.length;
    final nextExerciseBatchCount = remainingExerciseCount > _exercisePageSize
        ? _exercisePageSize
        : remainingExerciseCount;
    return ColoredBox(
      color: context.themeColors.pageBackground,
      child: RefreshIndicator(
        color: AppColors.teal520,
        onRefresh: _refreshClassrooms,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(title: context.getText(AppKeys.teacherStudyTitle)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  teacherTabContentHorizontalPadding,
                  teacherTabContentTopPadding,
                  teacherTabContentHorizontalPadding,
                  widget.bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TeacherClassroomAddButton(onTap: _openCreateExercise),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: TeacherStudySearchField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if (!_hasCompletedInitialLoad)
                      const Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: TeacherStudyLoadingIndicator(),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TeacherStudyClassFilters(
                              classrooms: _classrooms,
                              selectedClassroomId: _selectedClassroomId,
                              onSelected: _selectClassroom,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: TeacherStudyPurposeFilters(
                                selectedPurpose: _selectedPurpose,
                                onSelected: _selectPurpose,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child:
                                  _isLoadingExercises &&
                                      _exercises.isEmpty &&
                                      !_hasCompletedInitialLoad
                                  ? const TeacherStudyLoadingIndicator()
                                  : _displayError != null && _exercises.isEmpty
                                  ? AppRetryPanel(
                                      message: _displayError!,
                                      onRetry: _refreshClassrooms,
                                    )
                                  : _classrooms.isEmpty
                                  ? TeacherEmptyAssignmentsPanel(
                                      message: context.getText(
                                        AppKeys.teacherEmptyClassroomList,
                                      ),
                                    )
                                  : _exercises.isEmpty
                                  ? TeacherEmptyAssignmentsPanel(
                                      message:
                                          _searchController.text
                                              .trim()
                                              .isNotEmpty
                                          ? context.getText(
                                              AppKeys.teacherStudyNoResults,
                                            )
                                          : context.getText(
                                              teacherExerciseCopy(
                                                _selectedPurpose,
                                              ).emptyKey,
                                            ),
                                    )
                                  : Column(
                                      spacing: 14,
                                      children: [
                                        for (final exercise in visibleExercises)
                                          TeacherStudyExerciseCard(
                                            exercise: exercise,
                                            onTap: () =>
                                                _openExerciseDetail(exercise),
                                          ),
                                        if (remainingExerciseCount > 0)
                                          TeacherStudyLoadMoreButton(
                                            loadCount: nextExerciseBatchCount,
                                            onTap: _showMoreExercises,
                                          ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateState(VoidCallback update) => setState(update);
}
