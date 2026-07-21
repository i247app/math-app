import 'dart:async';

import 'package:flutter/material.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/network/classroom_models.dart';
import 'package:numi/core/theme/app_colors.dart';
import 'package:numi/shared/layouts/app_screen_app_bar.dart';
import 'package:numi/shared/widgets/app_retry_panel.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_empty_member_text.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_join_request_card.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_joined_member_card.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_add_button.dart';
import 'package:numi/features/classroom/widgets/teacher_members/teacher_member_section_title.dart';

class TeacherClassMembersContent extends StatelessWidget {
  const TeacherClassMembersContent({
    super.key,
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
                15,
                31,
                15,
                MediaQuery.paddingOf(context).bottom + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TeacherMemberAddButton(
                      onTap: isSendingInvites ? null : onOpenStudentSearch,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: isLoading && joinRequests.isEmpty && members.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.teal520,
                              ),
                            ),
                          )
                        : error != null &&
                              joinRequests.isEmpty &&
                              members.isEmpty
                        ? AppRetryPanel(message: error!, onRetry: onRefresh)
                        : _TeacherClassMembersLists(
                            joinRequests: joinRequests,
                            members: members,
                            processingProfileIds: processingProfileIds,
                            onApprove: onApprove,
                            onReject: onReject,
                          ),
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
    required this.joinRequests,
    required this.members,
    required this.processingProfileIds,
    required this.onApprove,
    required this.onReject,
  });
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
        TeacherMemberSectionTitle(
          title: context.formatText(AppKeys.teacherJoinRequests, {
            'count': joinRequests.length,
          }),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: TeacherJoinRequestCard(
            requests: joinRequests,
            processingProfileIds: processingProfileIds,
            onApprove: onApprove,
            onReject: onReject,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: TeacherMemberSectionTitle(
            title: context.formatText(AppKeys.teacherJoinedStudentsTitle, {
              'count': members.length,
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: members.isEmpty
              ? TeacherEmptyMemberText(
                  text: context.getText(AppKeys.teacherNoJoinedStudents),
                )
              : Column(
                  spacing: 12,
                  children: [
                    for (final member in members)
                      TeacherJoinedMemberCard(member: member),
                  ],
                ),
        ),
      ],
    );
  }
}
