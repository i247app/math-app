import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_exercise_models.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/network/grade_models.dart';
import 'package:numi/core/network/program_models.dart';
import 'package:numi/core/network/school_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/application/classroom_state.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/presentation/teacher_homework_screen.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/profile/data/profile_api.dart';
import 'package:numi/features/profile/data/school_api.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/features/classroom/data/cache/teacher_classroom_lookup_cache.dart';
import 'package:numi/features/classroom/presentation/screens/teacher_class_members_screen.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_info_card.dart';
import 'package:numi/features/classroom/widgets/teacher_detail/teacher_class_detail_lower_content.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  const TeacherClassDetailScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    this.userId,
    this.initialClassroom,
    this.initiallyExpanded = false,
    ClassroomService? classroomService,
    GradeService? gradeService,
    ProfileService? profileService,
    SchoolService? schoolService,
  }) : _classroomService = classroomService,
       _gradeService = gradeService,
       _profileService = profileService,
       _schoolService = schoolService;

  final int classroomId;
  final int profileId;
  final int? userId;
  final ClassroomModel? initialClassroom;
  final bool initiallyExpanded;
  final ClassroomService? _classroomService;
  final GradeService? _gradeService;
  final ProfileService? _profileService;
  final SchoolService? _schoolService;

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();
  late final GradeService _gradeService = widget._gradeService ?? GradeApi();
  late final ProfileService _profileService =
      widget._profileService ?? ProfileApi();
  late final SchoolService _schoolService =
      widget._schoolService ?? SchoolApi();

  late bool _isInfoExpanded;
  List<GradeModel> _grades = const <GradeModel>[];
  List<ProgramModel> _programs = const <ProgramModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];

  @override
  void initState() {
    super.initState();
    _isInfoExpanded = widget.initiallyExpanded;
    _loadDetail(forceRefresh: true);
    _loadLookupOptions();
  }

  Future<void> _loadDetail({bool forceRefresh = false}) {
    return context.read<ClassroomCubit>().loadDetail(
      profileId: widget.profileId,
      classroomId: widget.classroomId,
      initialClassroom: widget.initialClassroom,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadLookupOptions({bool forceRefresh = false}) async {
    final userId = widget.userId;
    if (userId == null || userId <= 0) {
      return;
    }

    final cachedOptions = TeacherClassroomLookupCache.shared.get(userId);
    if (!forceRefresh && cachedOptions != null) {
      setState(() => _applyLookupOptions(cachedOptions));
      unawaited(_loadLookupOptions(forceRefresh: true));
      return;
    }

    try {
      final options = await TeacherClassroomLookupCache.shared.load(
        userId: userId,
        gradeService: _gradeService,
        profileService: _profileService,
        schoolService: _schoolService,
        forceRefresh: forceRefresh,
      );
      if (!mounted) {
        return;
      }
      setState(() => _applyLookupOptions(options));
    } catch (_) {
      // Detail can still render backend ids if lookup endpoints fail.
    }
  }

  void _applyLookupOptions(TeacherClassroomLookupOptions options) {
    _grades = options.grades;
    _programs = options.programs;
    _schools = options.schools;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ClassroomCubit, ClassroomState, ClassroomDetailState>(
      selector: (state) => state.detail(widget.profileId, widget.classroomId),
      builder: (context, detailState) {
        final colors = context.themeColors;
        return Scaffold(
          backgroundColor: colors.pageBackground,
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = math.min(constraints.maxWidth / 390, 1.12);
                final classroom =
                    detailState.classroom ?? widget.initialClassroom;
                final students =
                    classroom?.students ?? const <ClassroomStudent>[];
                final count = classroom?.displayStudentCount ?? students.length;
                final requestCount = classroom?.displayPendingRequestCount ?? 0;

                return Column(
                  children: [
                    AppScreenAppBar(
                      backIconAsset: 'assets/images/teacher_class_back.svg',
                      title: context.getText(AppKeys.teacherClassDetailTitle),
                      scale: scale,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        color: colors.brandStrong,
                        onRefresh: () => _loadDetail(forceRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            16 * scale,
                            18 * scale,
                            16 * scale,
                            MediaQuery.paddingOf(context).bottom + 28 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (detailState.errorMessage != null &&
                                  classroom == null)
                                AppRetryPanel(
                                  scale: scale,
                                  message: detailState.errorMessage!,
                                  onRetry: () =>
                                      _loadDetail(forceRefresh: true),
                                )
                              else
                                TeacherClassDetailInfoCard(
                                  scale: scale,
                                  classroom: classroom,
                                  grades: _grades,
                                  programs: _programs,
                                  schools: _schools,
                                  isLoading:
                                      detailState.isLoading &&
                                      classroom == null,
                                  isExpanded: _isInfoExpanded,
                                  onToggleExpanded: _toggleInfoExpanded,
                                ),
                              if (detailState.errorMessage == null ||
                                  classroom != null)
                                TeacherClassDetailLowerContent(
                                  scale: scale,
                                  memberCount: count,
                                  requestCount: requestCount,
                                  onOpenAssignments: () =>
                                      _openHomework(classroom),
                                  onOpenAssessments: () =>
                                      _openAssessment(classroom),
                                  onOpenMembers: _openMembers,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleInfoExpanded() {
    HapticFeedback.selectionClick();
    setState(() => _isInfoExpanded = !_isInfoExpanded);
  }

  void _openHomework(ClassroomModel? classroom) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkScreen(
          classroomId: widget.classroomId,
          profileId: widget.profileId,
          userId: widget.userId,
          initialClassroom: classroom,
          purpose: classroomExercisePurposeHomework,
        ),
      ),
    );
  }

  void _openAssessment(ClassroomModel? classroom) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherHomeworkScreen(
          classroomId: widget.classroomId,
          profileId: widget.profileId,
          userId: widget.userId,
          initialClassroom: classroom,
          purpose: classroomExercisePurposeExam,
        ),
      ),
    );
  }

  Future<void> _openMembers() async {
    final classroomCubit = context.read<ClassroomCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: classroomCubit,
          child: TeacherClassMembersScreen(
            classroomId: widget.classroomId,
            profileId: widget.profileId,
            classroomService: _classroomService,
          ),
        ),
      ),
    );
    if (mounted) {
      _loadDetail(forceRefresh: true);
    }
  }
}
