part of 'package:numi/features/classroom/presentation/screens/teacher_classroom_screens.dart';

class _TeacherClassMembersContent extends StatelessWidget {
  const _TeacherClassMembersContent({
    required this.scale,
    required this.isLoading,
    required this.isSendingInvites,
    required this.error,
    required this.joinRequests,
    required this.members,
    required this.processingProfileIds,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenStudentSearch,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final bool isLoading;
  final bool isSendingInvites;
  final String? error;
  final List<ClassroomStudent> joinRequests;
  final List<ClassroomStudent> members;
  final Set<int> processingProfileIds;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenStudentSearch;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppScreenAppBar(
          backIconAsset: 'assets/images/teacher_class_back.svg',
          title: context.getText(AppKeys.teacherMembersTitle),
          scale: scale,
          onBack: onBack,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppColors.teal520,
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                15 * scale,
                31 * scale,
                15 * scale,
                MediaQuery.paddingOf(context).bottom + 32 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _TeacherMemberAddButton(
                      scale: scale,
                      onTap: isSendingInvites ? null : onOpenStudentSearch,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  if (isLoading && joinRequests.isEmpty && members.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 80 * scale),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.teal520,
                        ),
                      ),
                    )
                  else if (error != null &&
                      joinRequests.isEmpty &&
                      members.isEmpty)
                    AppRetryPanel(
                      scale: scale,
                      message: error!,
                      onRetry: onRefresh,
                    )
                  else
                    _TeacherClassMembersLists(
                      scale: scale,
                      joinRequests: joinRequests,
                      members: members,
                      processingProfileIds: processingProfileIds,
                      onApprove: onApprove,
                      onReject: onReject,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeacherClassMembersLists extends StatelessWidget {
  const _TeacherClassMembersLists({
    required this.scale,
    required this.joinRequests,
    required this.members,
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });

  final double scale;
  final List<ClassroomStudent> joinRequests;
  final List<ClassroomStudent> members;
  final Set<int> processingProfileIds;
  final ValueChanged<ClassroomStudent> onApprove;
  final ValueChanged<ClassroomStudent> onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeacherMemberSectionTitle(
          scale: scale,
          title: context.formatText(AppKeys.teacherJoinRequests, {
            'count': joinRequests.length,
          }),
        ),
        SizedBox(height: 10 * scale),
        _TeacherJoinRequestCard(
          scale: scale,
          requests: joinRequests,
          processingProfileIds: processingProfileIds,
          onApprove: onApprove,
          onReject: onReject,
        ),
        SizedBox(height: 28 * scale),
        _TeacherMemberSectionTitle(
          scale: scale,
          title: context.formatText(AppKeys.teacherJoinedStudentsTitle, {
            'count': members.length,
          }),
        ),
        SizedBox(height: 8 * scale),
        if (members.isEmpty)
          _TeacherEmptyMemberText(
            scale: scale,
            text: context.getText(AppKeys.teacherNoJoinedStudents),
          )
        else
          for (var index = 0; index < members.length; index++) ...[
            _TeacherJoinedMemberCard(scale: scale, member: members[index]),
            if (index != members.length - 1) SizedBox(height: 12 * scale),
          ],
      ],
    );
  }
}
