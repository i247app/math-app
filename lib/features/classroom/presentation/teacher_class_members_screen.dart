part of 'teacher_classroom_screens.dart';

class TeacherClassMembersScreen extends StatefulWidget {
  const TeacherClassMembersScreen({
    super.key,
    required this.classroomId,
    required this.profileId,
    ClassroomService? classroomService,
    ProfileService? profileService,
  })  : _classroomService = classroomService,
        _profileService = profileService;

  final int classroomId;
  final int profileId;
  final ClassroomService? _classroomService;
  final ProfileService? _profileService;

  @override
  State<TeacherClassMembersScreen> createState() =>
      _TeacherClassMembersScreenState();
}

class _TeacherClassMembersScreenState extends State<TeacherClassMembersScreen> {
  late final ClassroomService _classroomService =
      widget._classroomService ?? ClassroomApi();

  List<ClassroomStudent> _joinRequests = const <ClassroomStudent>[];
  List<ClassroomStudent> _members = const <ClassroomStudent>[];
  final Set<int> _processingProfileIds = <int>{};
  bool _isLoading = true;
  bool _isSendingInvites = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _classroomService.listJoinRequests(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
        ),
        _classroomService.listStudents(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
        ),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _joinRequests = results[0];
        _members = results[1];
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

  Future<void> _handleJoinRequest(
    ClassroomStudent request, {
    required bool approve,
  }) async {
    final targetProfileId = request.profileId;
    if (targetProfileId == null) {
      return;
    }
    setState(() => _processingProfileIds.add(targetProfileId));
    try {
      if (approve) {
        await _classroomService.approveJoinRequest(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
          targetProfileId: targetProfileId,
        );
      } else {
        await _classroomService.rejectJoinRequest(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
          targetProfileId: targetProfileId,
        );
      }
      await _loadMembers();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message, style: GoogleFonts.andika()),
            duration: const Duration(milliseconds: 1600),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingProfileIds.remove(targetProfileId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _teacherPaleMint,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final scale = math.min(constraints.maxWidth / 390, 1.12);
                return _TeacherClassMembersContent(
                  scale: scale,
                  isLoading: _isLoading,
                  isSendingInvites: _isSendingInvites,
                  error: _error,
                  joinRequests: _joinRequests,
                  members: _members,
                  processingProfileIds: _processingProfileIds,
                  onBack: () => Navigator.of(context).maybePop(),
                  onRefresh: _loadMembers,
                  onOpenStudentSearch: () => _openStudentSearchSheet(context),
                  onApprove: (request) => _handleJoinRequest(
                    request,
                    approve: true,
                  ),
                  onReject: (request) => _handleJoinRequest(
                    request,
                    approve: false,
                  ),
                );
              },
            ),
            if (_isSendingInvites) const _TeacherSendingInviteOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _openStudentSearchSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<List<StudentProfile>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TeacherStudentInviteSearchSheet(
        profileService: widget._profileService ?? ProfileApi(),
      ),
    );
    if (selected == null || selected.isEmpty || !context.mounted) {
      return;
    }
    final targetProfileIds = selected
        .map(ActiveProfileSession.profileStableId)
        .whereType<int>()
        .toList(growable: false);
    if (targetProfileIds.isEmpty) {
      return;
    }
    setState(() => _isSendingInvites = true);
    try {
      await _classroomService.sendInvitations(
        inviterProfileId: widget.profileId,
        classroomId: widget.classroomId,
        targetProfileIds: targetProfileIds,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.formatText(
                AppKeys.teacherInviteRequestQueued,
                {'count': targetProfileIds.length},
              ),
              style: GoogleFonts.andika(),
            ),
            duration: const Duration(milliseconds: 1400),
          ),
        );
    } on ClassroomException catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message, style: GoogleFonts.andika()),
            duration: const Duration(milliseconds: 1600),
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSendingInvites = false);
      }
    }
  }
}
