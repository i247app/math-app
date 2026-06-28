import 'package:flutter/material.dart';

import 'package:numi_flutter/core/extension/localization_extension.dart';
import 'package:numi_flutter/core/localization/app_keys.dart';
import 'package:numi_flutter/core/network/classroom_exercise_models.dart';
import 'package:numi_flutter/core/network/classroom_models.dart';
import 'package:numi_flutter/features/classroom/classroom_api.dart';
import 'package:numi_flutter/features/classroom/helpers/student_class_detail_helpers.dart';
import 'package:numi_flutter/features/classroom/presentation/student_class_detail_style.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_error_card.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_learning_category_section.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_teacher_profile_card.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_top_bar.dart';
import 'package:numi_flutter/features/classroom/widgets/student_detail/student_class_upcoming_deadline_section.dart';
import 'package:numi_flutter/features/homework/homework_api.dart';

class StudentClassDetailScreen extends StatefulWidget {
  const StudentClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.initialClassroom,
    ClassroomService? classroomService,
    ClassroomExerciseService? exerciseService,
  })  : _classroomService = classroomService,
        _exerciseService = exerciseService;

  final int classroomId;
  final int profileId;
  final ClassroomModel? initialClassroom;
  final ClassroomService? _classroomService;
  final ClassroomExerciseService? _exerciseService;

  @override
  State<StudentClassDetailScreen> createState() =>
      _StudentClassDetailScreenState();
}

class _StudentClassDetailScreenState extends State<StudentClassDetailScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final ClassroomExerciseService _exerciseService =
      widget._exerciseService ?? ClassroomExerciseApi();

  ClassroomModel? _classroom;
  List<ClassroomExercise> _homeworkExercises = const <ClassroomExercise>[];
  bool _isLoading = false;
  bool _isLoadingHomework = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _classroom = widget.initialClassroom;
    _loadDetail();
    _loadHomeworkExercises();
  }

  Future<void> _refresh() {
    return Future.wait<void>([
      _loadDetail(),
      _loadHomeworkExercises(),
    ]);
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final classroom = await _classroomService.getClassroomDetail(
        classroomId: widget.classroomId,
        profileId: widget.profileId,
      );
      if (!mounted) {
        return;
      }
      setState(() => _classroom = classroom ?? _classroom);
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    final classroom = _classroom;
    final title = studentClassNonEmpty(classroom?.name) ??
        context.getText(AppKeys.studentClassDetailTitle);

    return Scaffold(
      backgroundColor: studentClassBg,
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
                color: studentClassTeal,
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
                      if (_error != null && classroom == null)
                        StudentClassErrorCard(
                          message: _error!,
                          onRetry: _loadDetail,
                        )
                      else ...[
                        StudentClassTeacherProfileCard(
                          classroom: classroom,
                          isLoading: _isLoading && classroom == null,
                        ),
                        const SizedBox(height: 26),
                        StudentClassLearningCategorySection(
                          classroomId: widget.classroomId,
                          profileId: widget.profileId,
                          homeworkCount: _homeworkExercises.length,
                          isLoadingHomework:
                              _isLoadingHomework && _homeworkExercises.isEmpty,
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
  }
}
