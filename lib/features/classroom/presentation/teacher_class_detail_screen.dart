part of 'teacher_classroom_screens.dart';

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
  })  : _classroomService = classroomService,
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

  bool _isLoading = false;
  bool _isLoadingLookups = false;
  String? _error;
  late bool _isInfoExpanded;
  ClassroomModel? _classroom;
  List<GradeModel> _grades = const <GradeModel>[];
  List<ProgramModel> _programs = const <ProgramModel>[];
  List<SchoolModel> _schools = const <SchoolModel>[];

  @override
  void initState() {
    super.initState();
    _isInfoExpanded = widget.initiallyExpanded;
    _classroom = widget.initialClassroom;
    _loadDetail();
    _loadLookupOptions();
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
      setState(() {
        _classroom = classroom ?? _classroom;
      });
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

  Future<void> _loadLookupOptions() async {
    final userId = widget.userId;
    if (userId == null || userId <= 0) {
      return;
    }

    setState(() => _isLoadingLookups = true);
    try {
      final results = await Future.wait<Object>([
        _gradeService.listGrades(userId: userId),
        _profileService.listPrograms(userId: userId),
        _schoolService.listSchools(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _grades = results[0] as List<GradeModel>;
        _programs = results[1] as List<ProgramModel>;
        _schools = results[2] as List<SchoolModel>;
      });
    } catch (_) {
      // Detail can still render backend ids if lookup endpoints fail.
    } finally {
      if (mounted) {
        setState(() => _isLoadingLookups = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teacherPaleMint,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = math.min(constraints.maxWidth / 390, 1.12);
            final classroom = _classroom;
            final students = classroom?.students ?? const <ClassroomStudent>[];
            final count = classroom?.displayStudentCount ?? students.length;
            final requestCount = classroom?.displayPendingRequestCount ?? 0;

            return Column(
              children: [
                _TeacherScreenAppBar(
                  title: context.getText(AppKeys.teacherClassDetailTitle),
                  scale: scale,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: _teacherTeal,
                    onRefresh: _loadDetail,
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
                          if (_error != null && classroom == null)
                            _TeacherErrorPanel(
                              scale: scale,
                              message: _error!,
                              onRetry: _loadDetail,
                            )
                          else
                            _ClassDetailInfoCard(
                              scale: scale,
                              classroom: classroom,
                              grades: _grades,
                              programs: _programs,
                              schools: _schools,
                              isLoading: _isLoading && classroom == null,
                              isExpanded: _isInfoExpanded,
                              onToggleExpanded: () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _isInfoExpanded = !_isInfoExpanded,
                                );
                              },
                            ),
                          if (classroom != null &&
                              (_isLoading || _isLoadingLookups))
                            _TeacherBackgroundRefreshLabel(scale: scale),
                          if (_error == null || classroom != null)
                            _ClassDetailLowerContent(
                              scale: scale,
                              memberCount: count,
                              requestCount: requestCount,
                              onOpenAssignments: () {
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
                              },
                              onOpenAssessments: () {
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
                              },
                              onOpenMembers: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => TeacherClassMembersScreen(
                                      classroomId: widget.classroomId,
                                      profileId: widget.profileId,
                                      classroomService: _classroomService,
                                    ),
                                  ),
                                );
                                if (mounted) {
                                  _loadDetail();
                                }
                              },
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
  }
}

class _ClassDetailInfoCard extends StatelessWidget {
  const _ClassDetailInfoCard({
    required this.scale,
    required this.classroom,
    required this.grades,
    required this.programs,
    required this.schools,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final double scale;
  final ClassroomModel? classroom;
  final List<GradeModel> grades;
  final List<ProgramModel> programs;
  final List<SchoolModel> schools;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final title = _nonEmpty(classroom?.name) ??
        context.getText(AppKeys.teacherClassFallback);
    final grade = _classroomGradeLabel(context, classroom, grades);
    final program = _classroomProgramLabel(context, classroom, programs) ??
        context.getText(AppKeys.teacherProgramFallback);
    final schoolName = _classroomSchoolLabel(context, classroom, schools);
    final code = _classCode(classroom);
    final joinLink = 'numinumi.vn/join/$code';

    final radius = BorderRadius.circular(24 * scale);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading || isExpanded ? null : onToggleExpanded,
        borderRadius: radius,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              15 * scale,
              16 * scale,
              8 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius,
              border: Border.all(color: const Color(0x80CCCCCC)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x0D000000),
                  blurRadius: 10 * scale,
                  offset: Offset(3 * scale, 3 * scale),
                ),
              ],
            ),
            child: isLoading
                ? SizedBox(
                    height: 164 * scale,
                    child: const Center(
                      child: CircularProgressIndicator(color: _teacherTeal),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 67 * scale,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 71 * scale,
                              height: 64 * scale,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'assets/images/teacher_class_graduation.svg',
                                width: 40 * scale,
                                height: 40 * scale,
                              ),
                            ),
                            SizedBox(width: 15 * scale),
                            Expanded(
                              child: SizedBox(
                                height: 64 * scale,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.andika(
                                          color: _teacherInk,
                                          fontSize: 20 * scale,
                                          fontWeight: FontWeight.w700,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _copyClassroomInfo(
                                        context,
                                        joinLink,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(8 * scale),
                                      child: Padding(
                                        padding: EdgeInsets.all(4 * scale),
                                        child: Image.asset(
                                          'assets/images/teacher_class_share.png',
                                          width: 23 * scale,
                                          height: 23 * scale,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            alignment: const AlignmentDirectional(-1, -1),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: isExpanded
                            ? Column(
                                key: const ValueKey('class-meta-expanded'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12 * scale),
                                  SizedBox(
                                    height: 74 * scale,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _ClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_grade.png',
                                          text: grade,
                                        ),
                                        SizedBox(height: 5 * scale),
                                        _ClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_program.png',
                                          text: program,
                                        ),
                                        SizedBox(height: 5 * scale),
                                        _ClassDetailMetaRow(
                                          scale: scale,
                                          iconAsset:
                                              'assets/images/teacher_class_description.png',
                                          text: schoolName,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(
                                key: ValueKey('class-meta-collapsed'),
                              ),
                      ),
                      SizedBox(height: 14 * scale),
                      SizedBox(
                        height: 27 * scale,
                        child: Row(
                          children: [
                            _ClassCodeChip(
                              scale: scale,
                              code: code,
                              onCopy: () => _copyClassroomInfo(
                                context,
                                code,
                              ),
                            ),
                            const Spacer(),
                            Image.asset(
                              'assets/images/teacher_class_qr.png',
                              width: 18 * scale,
                              height: 18 * scale,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 11 * scale),
                      Container(
                        height: 38 * scale,
                        padding: EdgeInsets.symmetric(horizontal: 21 * scale),
                        decoration: BoxDecoration(
                          color: _teacherMint,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: const Color(0xFFEFF6FF)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                joinLink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: const Color(0xFF1E3A5F),
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w400,
                                  height: 1.7,
                                ),
                              ),
                            ),
                            SizedBox(width: 8 * scale),
                            InkWell(
                              onTap: () => _copyClassroomInfo(
                                context,
                                joinLink,
                              ),
                              borderRadius: BorderRadius.circular(8 * scale),
                              child: Padding(
                                padding: EdgeInsets.all(2 * scale),
                                child: SvgPicture.asset(
                                  'assets/images/teacher_class_copy.svg',
                                  width: 20 * scale,
                                  height: 20 * scale,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[
                        SizedBox(height: 16 * scale),
                        Center(
                          child: InkWell(
                            onTap: onToggleExpanded,
                            borderRadius: BorderRadius.circular(10 * scale),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 5 * scale,
                              ),
                              child: Text(
                                context.getText(AppKeys.teacherClassHideLess),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.andika(
                                  color: _teacherMuted,
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ClassDetailMetaRow extends StatelessWidget {
  const _ClassDetailMetaRow({
    required this.scale,
    required this.iconAsset,
    required this.text,
  });

  final double scale;
  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * scale,
      child: Row(
        children: [
          Image.asset(
            iconAsset,
            width: 18 * scale,
            height: 18 * scale,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.andika(
                color: const Color(0xFF001741),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCodeChip extends StatelessWidget {
  const _ClassCodeChip({
    required this.scale,
    required this.code,
    required this.onCopy,
  });

  final double scale;
  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 27 * scale,
      constraints: BoxConstraints(
        minWidth: 114 * scale,
        maxWidth: 190 * scale,
      ),
      padding: EdgeInsets.symmetric(horizontal: 17 * scale),
      decoration: BoxDecoration(
        color: _teacherMint,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                code,
                maxLines: 1,
                style: GoogleFonts.andika(
                  color: const Color(0xFF1E3A5F),
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.all(2 * scale),
              child: SvgPicture.asset(
                'assets/images/teacher_class_link_copy.svg',
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassDetailLowerContent extends StatelessWidget {
  const _ClassDetailLowerContent({
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
    required this.onOpenMembers,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;
  final VoidCallback onOpenMembers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MemberManagementCard(
            scale: scale,
            memberCount: memberCount,
            requestCount: requestCount,
            onTap: onOpenMembers,
          ),
          SizedBox(height: 27 * scale),
          Text(
            context.getText(AppKeys.teacherClassFunctions),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.andika(
              color: const Color(0xFF1E3A5F),
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              height: 1.55,
            ),
          ),
          SizedBox(height: 7 * scale),
          _ClassFunctionGrid(
            scale: scale,
            onOpenAssignments: onOpenAssignments,
            onOpenAssessments: onOpenAssessments,
          ),
        ],
      ),
    );
  }
}

class _MemberManagementCard extends StatelessWidget {
  const _MemberManagementCard({
    required this.scale,
    required this.memberCount,
    required this.requestCount,
    required this.onTap,
  });

  final double scale;
  final int memberCount;
  final int requestCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 77 * scale),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: 21 * scale,
              vertical: 14 * scale,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Image.asset(
                    'assets/images/teacher_class_members.png',
                    width: 28 * scale,
                    height: 28 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.getText(AppKeys.teacherMemberManagement),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: const Color(0xFF1E3A5F),
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          height: 1.22,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        _teacherMemberSummaryText(
                          context,
                          members: memberCount,
                          requests: requestCount,
                        ),
                        maxLines: requestCount > 0 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.andika(
                          color: _teacherMuted,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/teacher_class_chevron.svg',
                  width: 20 * scale,
                  height: 20 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassFunctionGrid extends StatelessWidget {
  const _ClassFunctionGrid({
    required this.scale,
    required this.onOpenAssignments,
    required this.onOpenAssessments,
  });

  final double scale;
  final VoidCallback onOpenAssignments;
  final VoidCallback onOpenAssessments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10 * scale,
      mainAxisSpacing: 10 * scale,
      childAspectRatio: 148 / 90,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _ClassFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/classroom_homework.png',
          label: context.getText(AppKeys.teacherAssignments),
          onTap: onOpenAssignments,
        ),
        _ClassFunctionTile(
          scale: scale,
          iconAsset: 'assets/images/teacher_class_assignment.png',
          label: context.getText(AppKeys.teacherAssessments),
          onTap: onOpenAssessments,
        ),
        _ClassFunctionTile(scale: scale),
        _ClassFunctionTile(scale: scale),
      ],
    );
  }
}

class _ClassFunctionTile extends StatelessWidget {
  const _ClassFunctionTile({
    required this.scale,
    this.iconAsset,
    this.label,
    this.onTap,
  });

  final double scale;
  final String? iconAsset;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16 * scale);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: const Color(0xFFDDE4E6),
              width: 2 * scale,
            ),
          ),
          child: iconAsset == null
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      iconAsset!,
                      width: 44 * scale,
                      height: 44 * scale,
                    ),
                    SizedBox(height: 1 * scale),
                    Text(
                      label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.andika(
                        color: _teacherInk,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String _detailIdLabel(String prefix, int? value) {
  final displayValue = _displayBackendId(value);
  if (displayValue == null) {
    return prefix;
  }
  return '$prefix $displayValue';
}

String? _displayBackendId(int? value) => value == null ? null : '$value';

String _classroomGradeLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<GradeModel> grades,
) {
  final grade = _matchGrade(grades, classroom?.gradeId);
  if (grade != null) {
    return _gradeLabel(grade);
  }
  return _detailIdLabel(context.getText(AppKeys.grade), classroom?.gradeId);
}

String? _classroomProgramLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<ProgramModel> programs,
) {
  final ids = _classroomProgramIds(classroom);
  final labels = <String>[];
  for (final id in ids) {
    final program = _matchProgram(programs, id);
    labels.add(
      program == null
          ? '${context.getText(AppKeys.teacherProgramFallback)} $id'
          : _programLabel(program),
    );
  }
  if (labels.isNotEmpty) {
    return labels.join(', ');
  }
  return null;
}

List<int> _classroomProgramIds(ClassroomModel? classroom) {
  if (classroom == null) {
    return const <int>[];
  }

  final ids = <int>[];
  void addId(int? id) {
    if (id != null && !ids.contains(id)) {
      ids.add(id);
    }
  }

  addId(classroom.programId);
  for (final id in classroom.programIds) {
    addId(id);
  }
  return ids;
}

String _classroomSchoolLabel(
  BuildContext context,
  ClassroomModel? classroom,
  List<SchoolModel> schools,
) {
  final school = _matchSchool(schools, classroom?.schoolId);
  if (school != null) {
    return _schoolLabel(school);
  }
  return _displayBackendId(classroom?.schoolId) ??
      context.getText(AppKeys.school);
}

String _classCode(ClassroomModel? classroom) {
  final classroomCode = _nonEmpty(classroom?.classroomCode);
  if (classroomCode != null) {
    return classroomCode;
  }
  final stableId = classroom?.stableId;
  if (stableId == null) {
    return 'NM-9988';
  }
  final cleaned = _displayClassStableId(stableId);
  if (cleaned.isEmpty) {
    return 'NM-9988';
  }
  final suffix = cleaned.length > 4
      ? cleaned.substring(cleaned.length - 4)
      : cleaned.padLeft(4, '0');
  return 'NM-$suffix';
}

String _displayClassStableId(int value) => '$value';

void _copyClassroomInfo(BuildContext context, String value) {
  Clipboard.setData(ClipboardData(text: value));
  HapticFeedback.selectionClick();
}
