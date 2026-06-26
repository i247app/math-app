part of '../../home_screen.dart';

class _StudentInvitationListScreen extends StatefulWidget {
  const _StudentInvitationListScreen({
    required this.profileId,
    required this.classroomService,
    required this.initialInvitations,
  });

  final int profileId;
  final ClassroomService classroomService;
  final List<ClassroomInvitation> initialInvitations;

  @override
  State<_StudentInvitationListScreen> createState() =>
      _StudentInvitationListScreenState();
}

class _StudentInvitationListScreenState
    extends State<_StudentInvitationListScreen> {
  List<ClassroomInvitation> _invitations = const <ClassroomInvitation>[];
  final Set<int> _processingClassroomIds = <int>{};
  bool _isLoading = false;
  bool _acceptedInvitation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _invitations = widget.initialInvitations;
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invitations = await widget.classroomService
          .listMyPendingInvitations(profileId: widget.profileId);
      if (!mounted) {
        return;
      }
      setState(() => _invitations = invitations);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = context.readText(AppKeys.studentInvitationLoadFailed);
        _invitations = const <ClassroomInvitation>[];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      } else {
        _isLoading = false;
      }
    }
  }

  Future<void> _handleInvitation(
    ClassroomInvitation invitation, {
    required bool accept,
  }) async {
    final classroomId = invitation.stableClassroomId;
    if (classroomId == null) {
      return;
    }

    final inviterProfileId = invitation.inviterProfileId ?? widget.profileId;
    setState(() => _processingClassroomIds.add(classroomId));
    try {
      if (accept) {
        await widget.classroomService.acceptInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
        _acceptedInvitation = true;
      } else {
        await widget.classroomService.rejectInvitation(
          inviteeProfileId: widget.profileId,
          inviterProfileId: inviterProfileId,
          classroomId: classroomId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              context.readText(
                accept
                    ? AppKeys.studentInvitationAcceptSuccess
                    : AppKeys.studentInvitationRejectSuccess,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      await _loadInvitations();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _processingClassroomIds.remove(classroomId));
      }
    }
  }

  void _close() {
    Navigator.of(context).pop(_acceptedInvitation);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: _close,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(context.getText(AppKeys.studentClassInvitations)),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadInvitations,
            color: _teal,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                if (_isLoading && _invitations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                    child:
                        Center(child: CircularProgressIndicator(color: _teal)),
                  )
                else if (_error != null && _invitations.isEmpty)
                  _StudentInlineErrorPanel(
                    message: _error!,
                    onRetry: _loadInvitations,
                  )
                else if (_invitations.isEmpty)
                  const _StudentStateCard(
                    titleKey: AppKeys.studentNoInvitationsTitle,
                    messageKey: AppKeys.studentNoInvitationsMessage,
                  )
                else
                  for (var index = 0; index < _invitations.length; index++) ...[
                    _StudentInvitationCard(
                      invitation: _invitations[index],
                      isProcessing: _processingClassroomIds.contains(
                        _invitations[index].stableClassroomId,
                      ),
                      onAccept: () => _handleInvitation(
                        _invitations[index],
                        accept: true,
                      ),
                      onReject: () => _handleInvitation(
                        _invitations[index],
                        accept: false,
                      ),
                    ),
                    if (index != _invitations.length - 1)
                      const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
