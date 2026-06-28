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
                            _TeacherClassDetailInfoCard(
                              scale: scale,
                              classroom: classroom,
                              grades: _grades,
                              programs: _programs,
                              schools: _schools,
                              isLoading: _isLoading && classroom == null,
                              isExpanded: _isInfoExpanded,
                              onToggleExpanded: _toggleInfoExpanded,
                            ),
                          if (classroom != null &&
                              (_isLoading || _isLoadingLookups))
                            _TeacherBackgroundRefreshLabel(scale: scale),
                          if (_error == null || classroom != null)
                            _TeacherClassDetailLowerContent(
                              scale: scale,
                              memberCount: count,
                              requestCount: requestCount,
                              onOpenAssignments: () => _openHomework(classroom),
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
  }
}
