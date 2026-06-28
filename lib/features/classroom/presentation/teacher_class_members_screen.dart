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

  final Set<int> _processingProfileIds = <int>{};
  bool _isSendingInvites = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers({bool forceRefresh = false}) {
    return context.read<ClassroomCubit>().loadMembers(
          profileId: widget.profileId,
          classroomId: widget.classroomId,
          forceRefresh: forceRefresh,
        );
  }

  Future<void> _handleJoinRequest(
    ClassroomStudent request, {
    required bool approve,
  }) async {
    final targetProfileId = request.profileId;
    if (targetProfileId == null) {
      return;
    }
    final cubit = context.read<ClassroomCubit>();
    final messenger = ScaffoldMessenger.of(context);
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
      cubit.invalidateClassroomData(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        detail: true,
        members: false,
      );
      await cubit.loadMembers(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        forceRefresh: true,
      );
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      messenger
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
                return BlocSelector<ClassroomCubit, ClassroomState,
                    ClassroomMembersState>(
                  selector: (state) => state.members(
                    widget.profileId,
                    widget.classroomId,
                  ),
                  builder: (context, membersState) {
                    return _TeacherClassMembersContent(
                      scale: scale,
                      isLoading: membersState.isLoading,
                      isSendingInvites: _isSendingInvites,
                      error: membersState.errorMessage,
                      joinRequests: membersState.joinRequests,
                      members: membersState.members,
                      processingProfileIds: _processingProfileIds,
                      onBack: () => Navigator.of(context).maybePop(),
                      onRefresh: () => _loadMembers(forceRefresh: true),
                      onOpenStudentSearch: () =>
                          _openStudentSearchSheet(context),
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
    final cubit = context.read<ClassroomCubit>();
    final messenger = ScaffoldMessenger.of(context);
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
    final successText = context.formatText(
      AppKeys.teacherInviteRequestQueued,
      {'count': targetProfileIds.length},
    );
    setState(() => _isSendingInvites = true);
    try {
      await _classroomService.sendInvitations(
        inviterProfileId: widget.profileId,
        classroomId: widget.classroomId,
        targetProfileIds: targetProfileIds,
      );
      cubit.invalidateClassroomData(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
      );
      await cubit.loadMembers(
        profileId: widget.profileId,
        classroomId: widget.classroomId,
        forceRefresh: true,
      );
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              successText,
              style: GoogleFonts.andika(),
            ),
            duration: const Duration(milliseconds: 1400),
          ),
        );
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      messenger
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
