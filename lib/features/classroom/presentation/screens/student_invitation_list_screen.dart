import 'package:flutter/material.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/classroom/errors/classroom_exception.dart';
import 'package:numi/shared/widgets/student/student_inline_error_panel.dart';
import 'package:numi/shared/widgets/student/student_state_card.dart';
import 'package:numi/features/classroom/widgets/student_invitations/student_invitation_card.dart';

class StudentInvitationListScreen extends StatefulWidget {
  const StudentInvitationListScreen({
    super.key,
    required this.profileId,
    required this.classroomService,
    required this.initialInvitations,
  });

  final int profileId;
  final ClassroomService classroomService;
  final List<ClassroomInvitation> initialInvitations;

  @override
  State<StudentInvitationListScreen> createState() =>
      _StudentInvitationListScreenState();
}

class _StudentInvitationListScreenState
    extends State<StudentInvitationListScreen> {
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
          // Note: classroomId is an int.
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
      await _loadInvitations();
    } on ClassroomException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorDialog(error.message);
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
        backgroundColor: context.themeColors.pageBackground,
        appBar: AppBar(
          backgroundColor: context.themeColors.elevatedSurface,
          surfaceTintColor: context.themeColors.elevatedSurface,
          leading: IconButton(
            onPressed: _close,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: context.themeColors.brandStrong,
            ),
          ),
          title: Text(
            context.getText(AppKeys.studentClassInvitations),
            style: TextStyle(color: context.themeColors.textPrimary),
          ),
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: _loadInvitations,
            color: context.themeColors.brandStrong,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                if (_isLoading && _invitations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.themeColors.brandStrong,
                      ),
                    ),
                  )
                else if (_error != null && _invitations.isEmpty)
                  StudentInlineErrorPanel(
                    message: _error!,
                    onRetry: _loadInvitations,
                  )
                else if (_invitations.isEmpty)
                  const StudentStateCard(
                    titleKey: AppKeys.studentNoInvitationsTitle,
                    messageKey: AppKeys.studentNoInvitationsMessage,
                  )
                else
                  for (var index = 0; index < _invitations.length; index++) ...[
                    StudentInvitationCard(
                      invitation: _invitations[index],
                      isProcessing: _processingClassroomIds.contains(
                        _invitations[index].stableClassroomId,
                      ),
                      onAccept: () =>
                          _handleInvitation(_invitations[index], accept: true),
                      onReject: () =>
                          _handleInvitation(_invitations[index], accept: false),
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
