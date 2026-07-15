import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/classroom_state.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_learning_category_section.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_teacher_profile_card.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_top_bar.dart';
import 'package:numi/features/classroom/widgets/student_detail/student_class_upcoming_deadline_section.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/homework/errors/classroom_exercise_exception.dart';

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
      widget._exerciseService ?? ClassroomExerciseApi();

  List<ClassroomExercise> _homeworkExercises = const <ClassroomExercise>[];
  bool _isLoadingHomework = false;

  @override
  void initState() {
    super.initState();
    _loadDetail(forceRefresh: true);
    _loadHomeworkExercises();
  }

  Future<void> _refresh() {
    return Future.wait<void>([
      _loadDetail(forceRefresh: true),
      _loadHomeworkExercises(),
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

  Future<void> _loadHomeworkExercises() async {
    setState(() => _isLoadingHomework = true);

    try {
      final exercises = await _exerciseService.listExercises(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
        visibility: 'PUBLIC',
      );
      if (!mounted) {
        return;
      }
      setState(() => _homeworkExercises = exercises);
    } on ClassroomExerciseException {
      if (!mounted) {
        return;
      }
      setState(() => _homeworkExercises = const <ClassroomExercise>[]);
    } finally {
      if (mounted) {
        setState(() => _isLoadingHomework = false);
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
                              scale: 1,
                              padding: 17,
                              borderRadius: 16,
                              messageFontSize: 14,
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
                            const SizedBox(height: 26),
                            StudentClassLearningCategorySection(
                              classroomId: widget.classroomId,
                              profileId: widget.profileId,
                              homeworkCount: _homeworkExercises.length,
                              isLoadingHomework:
                                  _isLoadingHomework &&
                                  _homeworkExercises.isEmpty,
                            ),
                            const SizedBox(height: 23),
                            StudentClassUpcomingDeadlineSection(
                              profileId: widget.profileId,
                              exercises: _homeworkExercises,
                              isLoading: _isLoadingHomework,
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
