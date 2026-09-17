import 'package:flutter/material.dart';
import 'package:numi/core/theme/font_size.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/features/classroom_exercise/models/classroom_exercise.dart';
import 'package:numi/features/classroom/models/classroom.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/features/classroom/controllers/classroom_cubit.dart';
import 'package:numi/features/classroom/controllers/classroom_state.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_learning_category_section.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_teacher_profile_card.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_top_bar.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_section.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_service.dart';
import 'package:numi/features/classroom_exercise/data/classroom_exercise_exception.dart';

class StudentClassDetailScreen extends StatefulWidget {
  const StudentClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.initialClassroom,
    ClassroomExerciseService? exerciseService,
  }) : _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final ClassroomModel? initialClassroom;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? context.read<ClassroomExerciseService>();

  List<ClassroomExercise> _classroomExerciseExercises =
      const <ClassroomExercise>[];
  bool _isLoadingClassroomExercise = false;

  @override
  void initState() {
    super.initState();
    _loadDetail(forceRefresh: true);
    _loadClassroomExerciseExercises();
  }

  Future<void> _refresh() {
    return Future.wait<void>([
      _loadDetail(forceRefresh: true),
      _loadClassroomExerciseExercises(),
    ]);
  }

  Future<void> _loadDetail({bool forceRefresh = false}) {
    return context.read<ClassroomCubit>().loadDetail(
      profileId: widget.profileId,
      classroomId: widget.classroomId,
      initialClassroom: widget.initialClassroom,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadClassroomExerciseExercises() async {
    setState(() => _isLoadingClassroomExercise = true);

    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        visibility: 'PUBLIC',
      );
      if (!mounted) {
        return;
      }
      setState(() => _classroomExerciseExercises = exercises);
    } on ClassroomExerciseException {
      if (!mounted) {
        return;
      }
      setState(() => _classroomExerciseExercises = const <ClassroomExercise>[]);
    } finally {
      if (mounted) {
        setState(() => _isLoadingClassroomExercise = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ClassroomCubit, ClassroomState, ClassroomDetailState>(
      selector: (state) => state.detail(widget.profileId, widget.classroomId),
      builder: (context, detailState) {
        final classroom = detailState.classroom ?? widget.initialClassroom;
        final title =
            studentClassNonEmpty(classroom?.name) ??
            context.getText(AppKeys.studentClassDetailTitle);
        final colors = context.themeColors;

        return Scaffold(
          backgroundColor: colors.pageBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                StudentClassTopBar(
                  title: title,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: colors.brandStrong,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        17,
                        16,
                        MediaQuery.paddingOf(context).bottom + 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (detailState.errorMessage != null &&
                              classroom == null)
                            AppRetryPanel(
                              padding: 17,
                              borderRadius: 16,
                              messageFontSize: FontSize.small,
                              messageFontWeight: FontWeight.w700,
                              filledAction: true,
                              message: detailState.errorMessage!,
                              onRetry: () => _loadDetail(forceRefresh: true),
                            )
                          else ...[
                            StudentClassTeacherProfileCard(
                              classroom: classroom,
                              isLoading:
                                  detailState.isLoading && classroom == null,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 26),
                              child: StudentClassLearningCategorySection(
                                classroomId: widget.classroomId,
                                profileId: widget.profileId,
                                classroomExerciseCount:
                                    _classroomExerciseExercises.length,
                                isLoadingClassroomExercise:
                                    _isLoadingClassroomExercise &&
                                    _classroomExerciseExercises.isEmpty,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 23),
                              child: StudentClassUpcomingDeadlineSection(
                                profileId: widget.profileId,
                                exercises: _classroomExerciseExercises,
                                isLoading: _isLoadingClassroomExercise,
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
      },
    );
  }
}
